<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.NhanVien, dao.DonHangDAO, util.Web"%>
<%
    request.setCharacterEncoding("UTF-8");
    NhanVien nv = Web.yeuCau(request, response, NhanVien.PHA_CHE);
    if (nv == null) return;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        int id = Web.soNguyen(request.getParameter("id"), -1);
        String tu = request.getParameter("tu");
        String den = "ChoPhaChe".equals(tu) ? "DangPhaChe" : "DangPhaChe".equals(tu) ? "HoanThanh" : null;
        boolean ok = false;
        if (id > 0 && den != null) {
            try (DonHangDAO dao = new DonHangDAO()) {
                ok = dao.capNhatTrangThai(id, nv.getChiNhanh().getId(), tu, den);
            }
        }
        if (!ok) Web.baoLoi(request, "Không cập nhật được trạng thái (đơn có thể đã được người khác xử lý).");
        else if ("HoanThanh".equals(den)) Web.baoTin(request, String.format("Đơn DH%06d đã hoàn thành.", id));
    }
    response.sendRedirect(request.getContextPath() + "/phache/GDPhaChe.jsp");
%>
