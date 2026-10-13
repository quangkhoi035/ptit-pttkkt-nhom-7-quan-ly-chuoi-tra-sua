<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, model.*, dao.TKChiNhanhDAO, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.QUAN_LY_CHUOI);
    if (nv == null) return;
    String tieuDe = "Thống kê doanh thu theo chi nhánh";
    String ctx = request.getContextPath();

    String sTu = request.getParameter("tuNgay");
    String sDen = request.getParameter("denNgay");
    boolean daGui = sTu != null || sDen != null;
    String loi = null;
    List<TKChiNhanh> ds = null;
    Date tu = Web.docNgay(sTu), den = Web.docNgay(sDen);

    if (!daGui) {
        // Mặc định: từ đầu tháng trước đến hôm nay
        Calendar c = Calendar.getInstance();
        sDen = Web.isoNgay(c.getTime());
        c.add(Calendar.MONTH, -1);
        c.set(Calendar.DAY_OF_MONTH, 1);
        sTu = Web.isoNgay(c.getTime());
    } else if (tu == null || den == null) {
        loi = "Vui lòng nhập đầy đủ khoảng thời gian.";
    } else if (den.before(tu)) {
        loi = "Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu.";
    } else if (tu.after(new Date())) {
        loi = "Khoảng thời gian không hợp lệ.";
    } else {
        try (TKChiNhanhDAO dao = new TKChiNhanhDAO()) {
            ds = dao.getTKChiNhanh(tu, den);
        }
        session.setAttribute("dsTK", ds);
    }
    int tongDon = 0;
    long tongDT = 0, maxDT = 1;
    if (ds != null) {
        for (TKChiNhanh tk : ds) {
            tongDon += tk.getSoDon();
            tongDT += tk.getDoanhThu();
            maxDT = Math.max(maxDT, tk.getDoanhThu());
        }
    }
%>
<%@include file="/Header.jsp"%>
<h1>THỐNG KÊ DOANH THU THEO CHI NHÁNH</h1>
<form method="get" class="row card" style="margin-bottom:16px">
    <label for="tu">Từ ngày</label>
    <input type="date" id="tu" name="tuNgay" value="<%= Web.h(sTu) %>">
    <label for="den">Đến ngày</label>
    <input type="date" id="den" name="denNgay" value="<%= Web.h(sDen) %>">
    <button class="btn">Thống kê</button>
</form>
<% if (loi != null) { %><div class="alert alert-err"><%= Web.h(loi) %></div><% } %>
<% if (ds != null && tongDon == 0) { %>
    <div class="alert alert-info">Không có dữ liệu doanh thu trong khoảng thời gian đã chọn.</div>
<% } else if (ds != null) { %>
    <p class="muted">Doanh thu = tổng thành tiền (sau giảm giá) của các đơn <b>Hoàn thành</b> từ
        <%= Web.ngay(tu) %> đến hết <%= Web.ngay(den) %>. Nhấp vào một dòng để xem danh sách đơn hàng.</p>
    <table class="tbl">
        <tr><th>STT</th><th>Mã CN</th><th>Tên chi nhánh</th><th class="num">Số đơn</th><th class="num" style="width:260px">Doanh thu (VNĐ)</th></tr>
        <% int stt = 0; for (TKChiNhanh tk : ds) { stt++;
           String link = ctx + "/quanlychuoi/GDDSDonHang.jsp?idCN=" + tk.getId() + "&tuNgay=" + Web.isoNgay(tu) + "&denNgay=" + Web.isoNgay(den); %>
        <tr class="click" onclick="location.href='<%= link %>'">
            <td><%= stt %></td>
            <td><a href="<%= link %>"><%= Web.h(tk.getMa()) %></a></td>
            <td><%= Web.h(tk.getTen()) %></td>
            <td class="num"><%= Web.tien(tk.getSoDon()) %></td>
            <td class="num"><%= Web.tien(tk.getDoanhThu()) %>
                <div class="bar"><span style="width:<%= Math.round(100.0 * tk.getDoanhThu() / maxDT) %>%"></span></div></td>
        </tr>
        <% } %>
        <tr class="total"><td></td><td></td><td>TỔNG CỘNG</td><td class="num"><%= Web.tien(tongDon) %></td><td class="num"><%= Web.tien(tongDT) %></td></tr>
    </table>
<% } %>
<p style="margin-top:20px"><a class="btn btn-ghost" href="<%= ctx %>/quanlychuoi/GDChonTK.jsp">Quay lại</a></p>
<%@include file="/Footer.jsp"%>
