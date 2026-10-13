<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.*, dao.DonHangDAO, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.QUAN_LY_CHUOI);
    if (nv == null) return;
    String ctx = request.getContextPath();
    int id = Web.soNguyen(request.getParameter("id"), -1);
    DonHang dh = null;
    if (id > 0) {
        try (DonHangDAO dao = new DonHangDAO()) {
            dh = dao.getChiTietDon(id);
        }
    }
    String quayLai = ctx + "/quanlychuoi/GDDSDonHang.jsp?idCN=" + Web.soNguyen(request.getParameter("idCN"), -1)
            + "&tuNgay=" + Web.isoNgay(Web.docNgay(request.getParameter("tuNgay")))
            + "&denNgay=" + Web.isoNgay(Web.docNgay(request.getParameter("denNgay")));
    if (dh == null) {
        Web.baoLoi(request, "Không tìm thấy đơn hàng.");
        response.sendRedirect(ctx + "/quanlychuoi/GDTKChiNhanh.jsp");
        return;
    }
    String tieuDe = "Chi tiết đơn " + dh.getMaDon();
%>
<%@include file="/Header.jsp"%>
<h1>CHI TIẾT ĐƠN <%= dh.getMaDon() %> – <%= Web.ngayGio(dh.getThoiGianTao()) %></h1>
<p class="muted">
    Chi nhánh: <%= Web.h(dh.getChiNhanh().getMa() + " " + dh.getChiNhanh().getTen()) %> ·
    Thu ngân: <%= Web.h(dh.getThuNgan().getHoTen()) %> ·
    Khách: <%= dh.getKhachHang() == null ? "(khách lẻ)" : Web.h(dh.getKhachHang().getHoTen() + " – " + dh.getKhachHang().getSdt()) %> ·
    <%= dh.getTenPhuongThucTT() %> · <span class="badge"><%= dh.getTenTrangThai() %></span>
</p>
<table class="tbl">
    <tr><th>Món</th><th>Size</th><th>Đường</th><th>Đá</th><th>Topping</th><th class="num">SL</th><th class="num">Thành tiền</th></tr>
    <% for (ChiTietDonHang ct : dh.getDsChiTiet()) { %>
    <tr>
        <td><%= Web.h(ct.getSanPhamKichCo().getSanPham().getTen()) %></td>
        <td><%= ct.getSanPhamKichCo().getKichCo().getMa() %></td>
        <td><%= ct.getMucDuong() %>%</td>
        <td><%= Web.h(ct.getMucDa()) %></td>
        <td><%= ct.getDsTopping().isEmpty() ? "–" : Web.h(ct.getMoTaTopping()) %></td>
        <td class="num"><%= ct.getSoLuong() %></td>
        <td class="num"><%= Web.tien(ct.getThanhTien()) %></td>
    </tr>
    <% } %>
</table>
<div class="card" style="max-width:360px;margin:16px 0 0 auto">
    <div class="sum"><span>Tổng tiền:</span><span><%= Web.tien(dh.getTongTien()) %></span></div>
    <div class="sum"><span>Khuyến mãi<%= dh.getKhuyenMai() == null ? "" : " " + Web.h(dh.getKhuyenMai().getMaCode()) %>:</span><span><%= dh.getGiamGia() > 0 ? "−" + Web.tien(dh.getGiamGia()) : "0" %></span></div>
    <div class="sum big"><span>Thành tiền:</span><span><%= Web.tien(dh.getThanhTien()) %></span></div>
</div>
<p style="margin-top:20px"><a class="btn btn-ghost" href="<%= quayLai %>">Quay lại</a></p>
<%@include file="/Footer.jsp"%>
