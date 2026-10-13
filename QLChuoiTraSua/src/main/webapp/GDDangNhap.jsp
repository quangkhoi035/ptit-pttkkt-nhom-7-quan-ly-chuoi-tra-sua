<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.NhanVien, util.Web"%>
<%
    NhanVien daDangNhap = (NhanVien) session.getAttribute("nhanVien");
    if (daDangNhap != null) {
        response.sendRedirect(request.getContextPath() + Web.trangChu(daDangNhap.getChucVu()));
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Đăng nhập – Trà sữa</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="topbar"><span class="brand">TRÀ SỮA – Hệ thống quản lý chuỗi</span></div>
<div class="login card">
    <h1>Đăng nhập</h1>
    <%= Web.flash(session) %>
    <form method="post" action="<%= request.getContextPath() %>/doDangNhap.jsp">
        <input type="text" name="tenDangNhap" placeholder="Tên đăng nhập" required autofocus maxlength="50">
        <input type="password" name="matKhau" placeholder="Mật khẩu" required maxlength="100">
        <button class="btn" type="submit">Đăng nhập</button>
    </form>
    <div class="hint">
        Hệ thống tự mở giao diện theo chức vụ.<br>
        Tài khoản mẫu (mật khẩu <b>123456</b>): <b>thungan01</b> (thu ngân CN01),
        <b>quanly</b> (quản lý chuỗi), <b>phache01</b> (pha chế CN01).
    </div>
</div>
</body>
</html>
