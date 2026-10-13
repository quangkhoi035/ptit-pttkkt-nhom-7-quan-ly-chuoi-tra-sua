<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.NhanVien, model.DonHang, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.THU_NGAN);
    if (nv == null) return;
    String tieuDe = "Giao diện chính thu ngân";
    DonHang dangLap = (DonHang) session.getAttribute("donHang");
    boolean coDonDo = dangLap != null && !dangLap.getDsChiTiet().isEmpty();
%>
<%@include file="/Header.jsp"%>
<h1>Xin chào, <%= Web.h(nv.getHoTen()) %></h1>
<p class="muted">Chi nhánh <%= Web.h(nv.getChiNhanh().getTen()) %> – <%= Web.h(nv.getChiNhanh().getDiaChi()) %></p>
<div class="tiles">
    <a class="tile" href="<%= request.getContextPath() %>/thungan/GDTaoDon.jsp">
        <%= coDonDo ? "Tiếp tục đơn đang lập" : "+ Tạo đơn mới" %>
        <small>Bán hàng tại quầy: chọn món, thành viên, khuyến mãi, thanh toán</small>
    </a>
    <span class="tile off" title="Ngoài phạm vi 2 module">Đơn chờ pha chế<small>Ngoài phạm vi module</small></span>
    <span class="tile off" title="Ngoài phạm vi 2 module">Đơn đã bán trong ca<small>Ngoài phạm vi module</small></span>
</div>
<%@include file="/Footer.jsp"%>
