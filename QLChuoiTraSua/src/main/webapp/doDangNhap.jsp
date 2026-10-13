<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.NhanVien, dao.NhanVienDAO, util.Web"%>
<%
    request.setCharacterEncoding("UTF-8");
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(request.getContextPath() + "/GDDangNhap.jsp");
        return;
    }
    String ten = request.getParameter("tenDangNhap");
    String mk = request.getParameter("matKhau");
    if (ten == null || ten.trim().isEmpty() || mk == null || mk.isEmpty()) {
        Web.baoLoi(request, "Vui lòng nhập tên đăng nhập và mật khẩu.");
        response.sendRedirect(request.getContextPath() + "/GDDangNhap.jsp");
        return;
    }
    NhanVien nv = new NhanVien();
    nv.setTenDangNhap(ten.trim());
    nv.setMatKhau(mk);
    boolean ok;
    try (NhanVienDAO dao = new NhanVienDAO()) {
        ok = dao.checkLogin(nv);
    }
    if (!ok) {
        Web.baoLoi(request, "Sai tên đăng nhập hoặc mật khẩu.");
        response.sendRedirect(request.getContextPath() + "/GDDangNhap.jsp");
        return;
    }
    if (NhanVien.QUAN_LY_CH.equals(nv.getChucVu())) {
        Web.baoLoi(request, "Chức năng của quản lý cửa hàng nằm ngoài phạm vi phiên bản này.");
        response.sendRedirect(request.getContextPath() + "/GDDangNhap.jsp");
        return;
    }
    // Tạo phiên mới sau khi đăng nhập (chống session fixation)
    session.invalidate();
    javax.servlet.http.HttpSession ss = request.getSession(true);
    ss.setAttribute("nhanVien", nv);
    response.sendRedirect(request.getContextPath() + Web.trangChu(nv.getChucVu()));
%>
