<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, model.*, dao.DonHangDAO, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.QUAN_LY_CHUOI);
    if (nv == null) return;
    String ctx = request.getContextPath();
    int idCN = Web.soNguyen(request.getParameter("idCN"), -1);
    Date tu = Web.docNgay(request.getParameter("tuNgay"));
    Date den = Web.docNgay(request.getParameter("denNgay"));
    if (idCN < 0 || tu == null || den == null || den.before(tu)) {
        Web.baoLoi(request, "Tham số không hợp lệ, vui lòng thống kê lại.");
        response.sendRedirect(ctx + "/quanlychuoi/GDTKChiNhanh.jsp");
        return;
    }
    String tenCN = "Chi nhánh #" + idCN;
    @SuppressWarnings("unchecked")
    List<TKChiNhanh> dsTK = (List<TKChiNhanh>) session.getAttribute("dsTK");
    if (dsTK != null) for (TKChiNhanh tk : dsTK) if (tk.getId() == idCN) tenCN = tk.getMa() + " " + tk.getTen();
    List<DonHang> ds;
    try (DonHangDAO dao = new DonHangDAO()) {
        ds = dao.getDSDonHang(idCN, tu, den);
    }
    long tong = 0;
    for (DonHang d : ds) tong += d.getThanhTien();
    String khoang = "tuNgay=" + Web.isoNgay(tu) + "&denNgay=" + Web.isoNgay(den);
    String tieuDe = "Đơn hàng " + tenCN;
%>
<%@include file="/Header.jsp"%>
<h1>ĐƠN HÀNG – <%= Web.h(tenCN) %> (<%= Web.ngay(tu) %> – <%= Web.ngay(den) %>)</h1>
<% if (ds.isEmpty()) { %>
    <div class="alert alert-info">Chi nhánh không có đơn hàng trong khoảng thời gian này.</div>
<% } else { %>
    <p class="muted">Tổng: <b><%= Web.tien(ds.size()) %></b> đơn hoàn thành · <b><%= Web.tien(tong) %></b> VNĐ</p>
    <table class="tbl">
        <tr><th>Mã đơn</th><th>Thời gian</th><th>Thu ngân</th><th>Khách hàng</th><th class="num">Thành tiền</th></tr>
        <% for (DonHang d : ds) {
           String link = ctx + "/quanlychuoi/GDChiTietDon.jsp?id=" + d.getId() + "&idCN=" + idCN + "&" + khoang; %>
        <tr class="click" onclick="location.href='<%= link %>'">
            <td><a href="<%= link %>"><%= d.getMaDon() %></a></td>
            <td><%= Web.ngayGio(d.getThoiGianTao()) %></td>
            <td><%= Web.h(d.getThuNgan().getHoTen()) %></td>
            <td><%= d.getKhachHang() == null ? "<span class=\"muted\">(khách lẻ)</span>" : Web.h(d.getKhachHang().getHoTen()) %></td>
            <td class="num"><%= Web.tien(d.getThanhTien()) %></td>
        </tr>
        <% } %>
    </table>
<% } %>
<p style="margin-top:20px"><a class="btn btn-ghost" href="<%= ctx %>/quanlychuoi/GDTKChiNhanh.jsp?<%= khoang %>">Quay lại</a></p>
<%@include file="/Footer.jsp"%>
