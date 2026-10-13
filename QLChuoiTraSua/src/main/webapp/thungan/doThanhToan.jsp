<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.*, dao.DonHangDAO, util.Web"%>
<%
    request.setCharacterEncoding("UTF-8");
    NhanVien nv = Web.yeuCau(request, response, NhanVien.THU_NGAN);
    if (nv == null) return;
    String ctx = request.getContextPath();
    DonHang dh = (DonHang) session.getAttribute("donHang");
    if (dh == null || dh.getDsChiTiet().isEmpty() || !"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(ctx + "/thungan/GDTaoDon.jsp");
        return;
    }
    dh.capNhatTien();
    String pt = request.getParameter("phuongThuc");
    if (!"TienMat".equals(pt) && !"ChuyenKhoan".equals(pt)) {
        Web.baoLoi(request, "Vui lòng chọn phương thức thanh toán.");
        response.sendRedirect(ctx + "/thungan/GDThanhToan.jsp");
        return;
    }
    long tien = "ChuyenKhoan".equals(pt) ? dh.getThanhTien() : Web.soLong(request.getParameter("tienKhachDua"), -1);
    if (tien < dh.getThanhTien()) {
        Web.baoLoi(request, "Số tiền khách đưa không đủ.");
        response.sendRedirect(ctx + "/thungan/GDThanhToan.jsp");
        return;
    }
    dh.setPhuongThucTT(pt);
    dh.setTienKhachDua(tien);
    boolean ok;
    String loi;
    try (DonHangDAO dao = new DonHangDAO()) {
        ok = dao.luuDonHang(dh);
        loi = dao.getLoi();
    }
    if (!ok) {
        Web.baoLoi(request, loi);
        response.sendRedirect(ctx + "/thungan/GDThanhToan.jsp");
        return;
    }
    if (dh.getKhachHang() != null) {
        ThanhVien tv = dh.getKhachHang();
        tv.setDiemTichLuy(tv.getDiemTichLuy() + (int) (dh.getThanhTien() / 10000));
    }
    session.setAttribute("hoaDon", dh);
    session.removeAttribute("donHang");
    session.removeAttribute("tvChuaCo");
    Web.baoTin(request, "Thanh toán thành công. Phiếu pha chế đã gửi sang quầy bar.");
    response.sendRedirect(ctx + "/thungan/GDHoaDon.jsp");
%>
