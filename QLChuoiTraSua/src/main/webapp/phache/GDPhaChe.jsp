<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, model.*, dao.DonHangDAO, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.PHA_CHE);
    if (nv == null) return;
    String tieuDe = "Phiếu pha chế";
    List<DonHang> ds = new ArrayList<>();
    try (DonHangDAO dao = new DonHangDAO()) {
        for (DonHang d : dao.getDSDonPhaChe(nv.getChiNhanh().getId())) {
            DonHang ct = dao.getChiTietDon(d.getId());
            if (ct != null) ds.add(ct);
        }
    }
%>
<%@include file="/Header.jsp"%>
<div class="row" style="justify-content:space-between">
    <h1>PHIẾU PHA CHẾ – <%= Web.h(nv.getChiNhanh().getTen()) %></h1>
    <a class="btn btn-ghost" href="">Làm mới</a>
</div>
<% if (ds.isEmpty()) { %>
    <div class="alert alert-info">Không có đơn nào đang chờ pha chế.</div>
<% } %>
<div class="queue">
    <% for (DonHang d : ds) { boolean dang = "DangPhaChe".equals(d.getTrangThai()); %>
    <div class="ticket <%= dang ? "dang" : "cho" %>">
        <div class="row" style="justify-content:space-between">
            <b><%= d.getMaDon() %></b><span class="badge"><%= d.getTenTrangThai() %></span>
        </div>
        <div class="muted"><%= Web.ngayGio(d.getThoiGianTao()) %> · <%= Web.h(d.getThuNgan().getHoTen()) %></div>
        <ul>
            <% for (ChiTietDonHang ct : d.getDsChiTiet()) { %>
            <li><b><%= ct.getSoLuong() %> × <%= Web.h(ct.getSanPhamKichCo().getSanPham().getTen()) %> (<%= ct.getSanPhamKichCo().getKichCo().getMa() %>)</b><br>
                <span class="muted"><%= ct.getMucDuong() %>% đường · <%= Web.h(ct.getMucDa()) %> đá<%= ct.getDsTopping().isEmpty() ? "" : " · + " + Web.h(ct.getMoTaTopping()) %></span></li>
            <% } %>
        </ul>
        <form method="post" action="<%= request.getContextPath() %>/phache/doPhaChe.jsp">
            <input type="hidden" name="id" value="<%= d.getId() %>">
            <% if (dang) { %>
                <input type="hidden" name="tu" value="DangPhaChe"><button class="btn" style="width:100%">Hoàn thành &amp; giao món</button>
            <% } else { %>
                <input type="hidden" name="tu" value="ChoPhaChe"><button class="btn btn-ghost" style="width:100%">Bắt đầu pha chế</button>
            <% } %>
        </form>
    </div>
    <% } %>
</div>
<%@include file="/Footer.jsp"%>
