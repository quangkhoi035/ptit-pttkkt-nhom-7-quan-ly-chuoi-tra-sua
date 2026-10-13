<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    session.invalidate();
    request.getSession(true).setAttribute("flashTin", "Đã đăng xuất.");
    response.sendRedirect(request.getContextPath() + "/GDDangNhap.jsp");
%>
