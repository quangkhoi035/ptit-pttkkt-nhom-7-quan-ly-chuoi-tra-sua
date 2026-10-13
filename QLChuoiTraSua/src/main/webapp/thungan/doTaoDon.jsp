<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, model.*, dao.ThanhVienDAO, dao.KhuyenMaiDAO, util.Web"%>
<%
    // Xử lý các thao tác trên giao diện tạo đơn (POST → redirect về GDTaoDon.jsp)
    request.setCharacterEncoding("UTF-8");
    NhanVien nv = Web.yeuCau(request, response, NhanVien.THU_NGAN);
    if (nv == null) return;
    String ve = request.getContextPath() + "/thungan/GDTaoDon.jsp";
    DonHang dh = (DonHang) session.getAttribute("donHang");
    if (dh == null || !"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(ve);
        return;
    }
    String action = String.valueOf(request.getParameter("action"));

    if ("them".equals(action)) {
        @SuppressWarnings("unchecked")
        List<SanPham> menu = (List<SanPham>) session.getAttribute("menu");
        @SuppressWarnings("unchecked")
        List<Topping> dsTopping = (List<Topping>) session.getAttribute("dsTopping");
        int idSPKC = Web.soNguyen(request.getParameter("idSPKC"), -1);
        SanPhamKichCo chon = null;
        if (menu != null) {
            for (SanPham sp : menu) {
                if (!sp.isDangBan()) continue;
                for (SanPhamKichCo g : sp.getDsGia()) if (g.getId() == idSPKC) chon = g;
            }
        }
        String duong = request.getParameter("mucDuong");
        String da = request.getParameter("mucDa");
        int sl = Web.soNguyen(request.getParameter("soLuong"), 0);
        List<String> hopLeDuong = Arrays.asList("0", "30", "50", "70", "100");
        List<String> hopLeDa = Arrays.asList("Không đá", "Ít", "Vừa", "Nhiều");
        if (chon == null) {
            Web.baoLoi(request, "Món không hợp lệ hoặc đã ngừng bán.");
        } else if (!hopLeDuong.contains(duong) || !hopLeDa.contains(da)) {
            Web.baoLoi(request, "Vui lòng chọn mức đường và mức đá.");
        } else if (sl < 1 || sl > 50) {
            Web.baoLoi(request, "Số lượng phải từ 1 đến 50.");
        } else {
            ChiTietDonHang ct = new ChiTietDonHang();
            ct.setSanPhamKichCo(chon);
            ct.setSoLuong(sl);
            ct.setMucDuong(duong);
            ct.setMucDa(da);
            ct.setDonGia(chon.getGia());
            String[] tps = request.getParameterValues("topping");
            if (tps != null && dsTopping != null) {
                for (String s : new LinkedHashSet<String>(Arrays.asList(tps))) {
                    int idTP = Web.soNguyen(s, -1);
                    for (Topping t : dsTopping) {
                        if (t.getId() == idTP) {
                            ChiTietTopping ctt = new ChiTietTopping();
                            ctt.setTopping(t);
                            ctt.setSoLuong(1);
                            ctt.setDonGia(t.getGia());
                            ct.getDsTopping().add(ctt);
                        }
                    }
                }
            }
            dh.getDsChiTiet().add(ct);
        }
    } else if ("xoa".equals(action)) {
        int i = Web.soNguyen(request.getParameter("dong"), -1);
        if (i >= 0 && i < dh.getDsChiTiet().size()) dh.getDsChiTiet().remove(i);
    } else if ("timTV".equals(action)) {
        String sdt = request.getParameter("sdt") == null ? "" : request.getParameter("sdt").replaceAll("\\s", "");
        if (!sdt.matches("0\\d{9}")) {
            Web.baoLoi(request, "Số điện thoại không hợp lệ.");
        } else {
            ThanhVien tv;
            try (ThanhVienDAO dao = new ThanhVienDAO()) {
                tv = dao.timTheoSDT(sdt);
            }
            if (tv == null) {
                session.setAttribute("tvChuaCo", sdt);
            } else {
                dh.setKhachHang(tv);
                session.removeAttribute("tvChuaCo");
            }
        }
    } else if ("dangKyTV".equals(action)) {
        String sdt = (String) session.getAttribute("tvChuaCo");
        String hoTen = request.getParameter("hoTen") == null ? "" : request.getParameter("hoTen").trim();
        if (sdt == null) {
            Web.baoLoi(request, "Vui lòng tìm số điện thoại trước.");
        } else if (hoTen.isEmpty() || hoTen.length() > 100) {
            Web.baoLoi(request, "Vui lòng nhập họ tên khách (tối đa 100 ký tự).");
        } else {
            ThanhVien tv = new ThanhVien();
            tv.setHoTen(hoTen);
            tv.setSdt(sdt);
            boolean ok;
            try (ThanhVienDAO dao = new ThanhVienDAO()) {
                ok = dao.themThanhVien(tv);
            }
            if (ok) {
                dh.setKhachHang(tv);
                session.removeAttribute("tvChuaCo");
                Web.baoTin(request, "Đã đăng ký thành viên " + hoTen + ".");
            } else {
                Web.baoLoi(request, "Không đăng ký được: số điện thoại có thể đã tồn tại.");
            }
        }
    } else if ("boQuaTV".equals(action)) {
        session.removeAttribute("tvChuaCo");
    } else if ("boChonTV".equals(action)) {
        dh.setKhachHang(null);
    } else if ("apKM".equals(action)) {
        String ma = request.getParameter("maCode") == null ? "" : request.getParameter("maCode").trim().toUpperCase();
        if (ma.isEmpty()) {
            Web.baoLoi(request, "Vui lòng nhập mã khuyến mãi.");
        } else {
            KhuyenMai km;
            try (KhuyenMaiDAO dao = new KhuyenMaiDAO()) {
                km = dao.kiemTraMa(ma);
            }
            dh.capNhatTien();
            if (km == null) {
                Web.baoLoi(request, "Mã khuyến mãi không hợp lệ hoặc đã hết hạn.");
            } else if (dh.getTongTien() < km.getDonToiThieu()) {
                Web.baoLoi(request, "Đơn hàng chưa đạt giá trị tối thiểu " + Web.tien(km.getDonToiThieu())
                        + "đ để áp dụng mã.");
            } else {
                dh.setKhuyenMai(km);
            }
        }
    } else if ("boKM".equals(action)) {
        dh.setKhuyenMai(null);
    } else if ("huy".equals(action)) {
        session.removeAttribute("donHang");
        session.removeAttribute("tvChuaCo");
        Web.baoTin(request, "Đã hủy đơn đang lập.");
        response.sendRedirect(request.getContextPath() + "/thungan/GDChinhThuNgan.jsp");
        return;
    } else if ("thanhToan".equals(action)) {
        dh.capNhatTien();
        if (dh.getDsChiTiet().isEmpty()) {
            Web.baoLoi(request, "Đơn chưa có món nào.");
        } else {
            response.sendRedirect(request.getContextPath() + "/thungan/GDThanhToan.jsp");
            return;
        }
    }

    // Tính lại tiền; bỏ mã nếu đơn không còn đạt giá trị tối thiểu
    dh.capNhatTien();
    if (dh.getKhuyenMai() != null && dh.getTongTien() < dh.getKhuyenMai().getDonToiThieu()) {
        Web.baoLoi(request, "Đã bỏ mã " + dh.getKhuyenMai().getMaCode() + " vì đơn không còn đạt giá trị tối thiểu.");
        dh.setKhuyenMai(null);
        dh.capNhatTien();
    }
    response.sendRedirect(ve);
%>
