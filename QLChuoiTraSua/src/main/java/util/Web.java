package util;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/** Các hàm tiện ích dùng chung cho trang JSP. */
public final class Web {

    private Web() {
    }

    /** Chống XSS khi in dữ liệu ra HTML. */
    public static String h(Object o) {
        if (o == null) {
            return "";
        }
        String s = o.toString();
        StringBuilder sb = new StringBuilder(s.length());
        for (char c : s.toCharArray()) {
            switch (c) {
                case '<': sb.append("&lt;"); break;
                case '>': sb.append("&gt;"); break;
                case '&': sb.append("&amp;"); break;
                case '"': sb.append("&quot;"); break;
                case '\'': sb.append("&#39;"); break;
                default: sb.append(c);
            }
        }
        return sb.toString();
    }

    /** 129000 -> "129.000" */
    public static String tien(long v) {
        DecimalFormatSymbols sym = new DecimalFormatSymbols(new Locale("vi", "VN"));
        sym.setGroupingSeparator('.');
        return new DecimalFormat("#,##0", sym).format(v);
    }

    public static String ngay(Date d) {
        return d == null ? "" : new SimpleDateFormat("dd/MM/yyyy").format(d);
    }

    public static String ngayGio(Date d) {
        return d == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(d);
    }

    /** yyyy-MM-dd (định dạng của ô input type=date) -> Date; sai định dạng trả về null. */
    public static Date docNgay(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            SimpleDateFormat f = new SimpleDateFormat("yyyy-MM-dd");
            f.setLenient(false);
            return f.parse(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    public static String isoNgay(Date d) {
        return d == null ? "" : new SimpleDateFormat("yyyy-MM-dd").format(d);
    }

    public static int soNguyen(String s, int macDinh) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return macDinh;
        }
    }

    public static long soLong(String s, long macDinh) {
        try {
            return Long.parseLong(s.trim().replace(".", "").replace(",", ""));
        } catch (Exception e) {
            return macDinh;
        }
    }

    /** Trang chính theo chức vụ (đường dẫn tương đối với context path). */
    public static String trangChu(String chucVu) {
        if (model.NhanVien.THU_NGAN.equals(chucVu)) return "/thungan/GDChinhThuNgan.jsp";
        if (model.NhanVien.QUAN_LY_CHUOI.equals(chucVu)) return "/quanlychuoi/GDChinhQLC.jsp";
        if (model.NhanVien.PHA_CHE.equals(chucVu)) return "/phache/GDPhaChe.jsp";
        return "/GDDangNhap.jsp";
    }

    /**
     * Kiểm tra đăng nhập và quyền. Trả về nhân viên đang đăng nhập, hoặc null sau khi đã
     * chuyển hướng (trang JSP gọi xong phải {@code return} ngay khi nhận null).
     */
    public static model.NhanVien yeuCau(HttpServletRequest req, javax.servlet.http.HttpServletResponse resp,
            String chucVu) throws java.io.IOException {
        HttpSession ss = req.getSession(false);
        model.NhanVien nv = ss == null ? null : (model.NhanVien) ss.getAttribute("nhanVien");
        if (nv == null) {
            req.getSession().setAttribute("flashLoi", "Vui lòng đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/GDDangNhap.jsp");
            return null;
        }
        if (chucVu != null && !chucVu.equals(nv.getChucVu())) {
            ss.setAttribute("flashLoi", "Bạn không có quyền truy cập chức năng đó.");
            resp.sendRedirect(req.getContextPath() + trangChu(nv.getChucVu()));
            return null;
        }
        return nv;
    }

    /** Lưu thông báo hiển thị một lần ở trang kế tiếp (flash message). */
    public static void baoLoi(HttpServletRequest req, String msg) {
        req.getSession().setAttribute("flashLoi", msg);
    }

    public static void baoTin(HttpServletRequest req, String msg) {
        req.getSession().setAttribute("flashTin", msg);
    }

    /** Lấy và xóa flash message; trả về HTML hộp thông báo (rỗng nếu không có). */
    public static String flash(HttpSession ss) {
        StringBuilder sb = new StringBuilder();
        Object loi = ss.getAttribute("flashLoi");
        Object tin = ss.getAttribute("flashTin");
        if (loi != null) {
            sb.append("<div class=\"alert alert-err\">").append(h(loi)).append("</div>");
            ss.removeAttribute("flashLoi");
        }
        if (tin != null) {
            sb.append("<div class=\"alert alert-ok\">").append(h(tin)).append("</div>");
            ss.removeAttribute("flashTin");
        }
        return sb.toString();
    }
}
