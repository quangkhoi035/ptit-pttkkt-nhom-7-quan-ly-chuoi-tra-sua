<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.NhanVien, util.Web"%>
<%
    NhanVien nv = Web.yeuCau(request, response, NhanVien.QUAN_LY_CHUOI);
    if (nv == null) return;
    String tieuDe = "Chọn loại thống kê";
%>
<%@include file="/Header.jsp"%>
<h1>XEM BÁO CÁO – chọn loại thống kê</h1>
<div class="tiles">
    <a class="tile" href="<%= request.getContextPath() %>/quanlychuoi/GDTKChiNhanh.jsp">Doanh thu theo chi nhánh<small>Số đơn và doanh thu từng chi nhánh theo khoảng thời gian</small></a>
    <span class="tile off">Sản phẩm bán chạy<small>Ngoài phạm vi module</small></span>
    <span class="tile off">Khách hàng thân thiết<small>Ngoài phạm vi module</small></span>
</div>
<p style="margin-top:20px"><a class="btn btn-ghost" href="<%= request.getContextPath() %>/quanlychuoi/GDChinhQLC.jsp">Quay lại</a></p>
<%@include file="/Footer.jsp"%>
