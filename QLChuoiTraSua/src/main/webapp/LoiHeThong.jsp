<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lỗi – Trà sữa</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>
<div class="topbar"><span class="brand">TRÀ SỮA – Hệ thống quản lý chuỗi</span></div>
<div class="wrap">
    <div class="card" style="max-width:560px;margin:40px auto">
        <h1>Đã có lỗi xảy ra</h1>
        <% Integer code = (Integer) request.getAttribute("javax.servlet.error.status_code"); %>
        <% if (code != null && code == 404) { %>
        <p>Không tìm thấy trang bạn yêu cầu.</p>
        <% } else { %>
        <p>Hệ thống gặp sự cố khi xử lý yêu cầu. Kiểm tra lại kết nối CSDL trong <code>db.properties</code> rồi thử lại.</p>
        <% if (exception != null) { %><p class="muted"><%= util.Web.h(exception.getMessage()) %></p><% } %>
        <% } %>
        <a class="btn" href="<%= request.getContextPath() %>/GDDangNhap.jsp">Về trang đăng nhập</a>
    </div>
</div>
</body>
</html>
