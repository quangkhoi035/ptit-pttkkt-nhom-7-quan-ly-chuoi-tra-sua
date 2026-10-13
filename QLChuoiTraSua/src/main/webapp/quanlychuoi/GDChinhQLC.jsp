<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.NhanVien, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.QUAN_LY_CHUOI);
    if (nv == null) return;
    String tieuDe = "Giao diện chính quản lý chuỗi";
%>
<%@include file="/Header.jsp"%>
<h1>Xin chào, <%= Web.h(nv.getHoTen()) %></h1>
<p class="muted">Quản lý chuỗi cửa hàng trà sữa</p>
<div class="tiles">
    <a class="tile" href="<%= request.getContextPath() %>/quanlychuoi/GDChonTK.jsp">Xem báo cáo<small>Thống kê doanh thu, sản phẩm, khách hàng</small></a>
    <span class="tile off">Quản lý chi nhánh<small>Ngoài phạm vi module</small></span>
    <span class="tile off">Quản lý thực đơn &amp; topping<small>Ngoài phạm vi module</small></span>
    <span class="tile off">Quản lý khuyến mãi<small>Ngoài phạm vi module</small></span>
</div>
<%@include file="/Footer.jsp"%>
