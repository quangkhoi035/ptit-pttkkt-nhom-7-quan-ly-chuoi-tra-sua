<%@page pageEncoding="UTF-8"%>
<%-- Phần đầu trang dùng chung. Trang gọi phải khai báo trước: NhanVien nv, String tieuDe --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= util.Web.h(tieuDe) %> – Trà sữa</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="topbar">
    <a class="brand" href="<%= request.getContextPath() + util.Web.trangChu(nv.getChucVu()) %>">TRÀ SỮA – Hệ thống quản lý chuỗi</a>
    <div class="who">
        <% if (nv.getChiNhanh() != null) { %><%= util.Web.h(nv.getChiNhanh().getMa() + " " + nv.getChiNhanh().getTen()) %> · <% } %>
        <%= util.Web.h(nv.getTenChucVu()) %>: <b><%= util.Web.h(nv.getHoTen()) %></b>
        <a href="<%= request.getContextPath() %>/DangXuat.jsp">Đăng xuất</a>
    </div>
</div>
<div class="wrap">
<%= util.Web.flash(session) %>
