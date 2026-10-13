<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.*, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.THU_NGAN);
    if (nv == null) return;
    DonHang dh = (DonHang) session.getAttribute("hoaDon");
    if (dh == null) {
        response.sendRedirect(request.getContextPath() + "/thungan/GDTaoDon.jsp");
        return;
    }
    String tieuDe = "Hóa đơn " + dh.getMaDon();
%>
<%@include file="/Header.jsp"%>
<div class="receipt">
    <h2>TRÀ SỮA – <%= Web.h(dh.getChiNhanh().getTen()) %></h2>
    <div class="center muted"><%= Web.h(dh.getChiNhanh().getDiaChi()) %></div>
    <hr>
    <div>Hóa đơn: <b><%= dh.getMaDon() %></b></div>
    <div>Thời gian: <%= Web.ngayGio(dh.getThoiGianTao()) %></div>
    <div>Thu ngân: <%= Web.h(dh.getThuNgan().getHoTen()) %></div>
    <% if (dh.getKhachHang() != null) { %><div>Thành viên: <%= Web.h(dh.getKhachHang().getHoTen()) %> (<%= dh.getKhachHang().getDiemTichLuy() %> điểm)</div><% } %>
    <hr>
    <table>
        <% for (ChiTietDonHang ct : dh.getDsChiTiet()) { %>
        <tr>
            <td><%= ct.getSoLuong() %> × <%= Web.h(ct.getSanPhamKichCo().getSanPham().getTen()) %> (<%= ct.getSanPhamKichCo().getKichCo().getMa() %>)
                <div class="muted"><%= ct.getMucDuong() %>% đường · <%= Web.h(ct.getMucDa()) %> đá<%= ct.getDsTopping().isEmpty() ? "" : " · + " + Web.h(ct.getMoTaTopping()) %></div></td>
            <td class="right"><%= Web.tien(ct.getThanhTien()) %></td>
        </tr>
        <% } %>
    </table>
    <hr>
    <table>
        <tr><td>Tổng tiền</td><td class="right"><%= Web.tien(dh.getTongTien()) %></td></tr>
        <% if (dh.getGiamGia() > 0) { %><tr><td>Giảm giá (<%= Web.h(dh.getKhuyenMai().getMaCode()) %>)</td><td class="right">−<%= Web.tien(dh.getGiamGia()) %></td></tr><% } %>
        <tr><td><b>THÀNH TIỀN</b></td><td class="right"><b><%= Web.tien(dh.getThanhTien()) %></b></td></tr>
        <tr><td><%= dh.getTenPhuongThucTT() %></td><td class="right"><%= Web.tien(dh.getTienKhachDua()) %></td></tr>
        <% if ("TienMat".equals(dh.getPhuongThucTT())) { %><tr><td>Tiền thừa</td><td class="right"><%= Web.tien(dh.getTienKhachDua() - dh.getThanhTien()) %></td></tr><% } %>
    </table>
    <hr>
    <div class="center muted">Cảm ơn quý khách!</div>
</div>
<div class="row no-print" style="justify-content:center;margin-top:16px">
    <button class="btn btn-ghost" onclick="window.print()">In hóa đơn</button>
    <a class="btn" href="<%= request.getContextPath() %>/thungan/GDTaoDon.jsp">+ Tạo đơn mới</a>
</div>
<%@include file="/Footer.jsp"%>
