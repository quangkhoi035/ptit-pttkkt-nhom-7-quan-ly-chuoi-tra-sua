package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.ChiNhanh;
import model.ChiTietDonHang;
import model.ChiTietTopping;
import model.DonHang;
import model.KhuyenMai;
import model.KichCo;
import model.NhanVien;
import model.SanPham;
import model.SanPhamKichCo;
import model.ThanhVien;
import model.Topping;

public class DonHangDAO extends DAO {

    private String loi;

    /** Lý do lỗi của lần lưu gần nhất (để hiển thị cho người dùng). */
    public String getLoi() {
        return loi;
    }

    /**
     * Lưu đơn hàng trong MỘT giao tác: đơn, chi tiết, topping, trừ lượt khuyến mãi, cộng điểm.
     * Lỗi ở bất kỳ bước nào thì rollback toàn bộ (ngoại lệ 14.1 của kịch bản).
     */
    public boolean luuDonHang(DonHang dh) {
        loi = null;
        try {
            con.setAutoCommit(false);
            try (CallableStatement cs = con.prepareCall("{call sp_TaoDonHang(?,?,?,?,?,?,?,?,?,?)}")) {
                cs.setInt(1, dh.getChiNhanh().getId());
                cs.setInt(2, dh.getThuNgan().getIdNhanVien());
                if (dh.getKhachHang() != null) cs.setInt(3, dh.getKhachHang().getId());
                else cs.setNull(3, Types.INTEGER);
                if (dh.getKhuyenMai() != null) cs.setInt(4, dh.getKhuyenMai().getId());
                else cs.setNull(4, Types.INTEGER);
                cs.setLong(5, dh.getTongTien());
                cs.setLong(6, dh.getGiamGia());
                cs.setLong(7, dh.getThanhTien());
                cs.setString(8, dh.getPhuongThucTT());
                cs.setLong(9, dh.getTienKhachDua());
                cs.registerOutParameter(10, Types.INTEGER);
                cs.execute();
                dh.setId(cs.getInt(10));
            }
            for (ChiTietDonHang ct : dh.getDsChiTiet()) {
                int idCT;
                try (CallableStatement c2 = con.prepareCall("{call sp_ThemChiTietDon(?,?,?,?,?,?,?,?)}")) {
                    c2.setInt(1, dh.getId());
                    c2.setInt(2, ct.getSanPhamKichCo().getId());
                    c2.setInt(3, ct.getSoLuong());
                    c2.setString(4, ct.getMucDuong());
                    c2.setString(5, ct.getMucDa());
                    c2.setLong(6, ct.getDonGia());
                    c2.setLong(7, ct.tinhThanhTien());
                    c2.registerOutParameter(8, Types.INTEGER);
                    c2.execute();
                    idCT = c2.getInt(8);
                    ct.setId(idCT);
                }
                for (ChiTietTopping tp : ct.getDsTopping()) {
                    try (CallableStatement c3 = con.prepareCall("{call sp_ThemChiTietTopping(?,?,?,?)}")) {
                        c3.setInt(1, idCT);
                        c3.setInt(2, tp.getTopping().getId());
                        c3.setInt(3, tp.getSoLuong());
                        c3.setLong(4, tp.getDonGia());
                        c3.execute();
                    }
                }
            }
            if (dh.getKhuyenMai() != null) {
                try (CallableStatement c4 = con.prepareCall("{call sp_TruLuotKhuyenMai(?)}")) {
                    c4.setInt(1, dh.getKhuyenMai().getId());
                    c4.execute();
                }
            }
            if (dh.getKhachHang() != null) {
                try (CallableStatement c5 = con.prepareCall("{call sp_CongDiem(?,?)}")) {
                    c5.setInt(1, dh.getKhachHang().getId());
                    c5.setLong(2, dh.getThanhTien());
                    c5.execute();
                }
            }
            con.commit();
            dh.setTrangThai("ChoPhaChe");
            dh.setThoiGianTao(new Date());
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            try {
                con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            dh.setId(0);
            String m = e.getMessage() == null ? "" : e.getMessage();
            loi = m.contains("khuyen mai") ? "Mã khuyến mãi vừa hết lượt hoặc hết hạn, vui lòng bỏ mã và thử lại."
                    : "Lưu đơn thất bại, vui lòng thử lại.";
            return false;
        } finally {
            try {
                con.setAutoCommit(true);
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
    }

    /** Danh sách đơn Hoàn thành của một chi nhánh trong khoảng ngày, mới nhất trước. */
    public List<DonHang> getDSDonHang(int idChiNhanh, Date tuNgay, Date denNgay) {
        List<DonHang> kq = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call sp_DSDonHangChiNhanh(?,?,?)}")) {
            cs.setInt(1, idChiNhanh);
            cs.setDate(2, new java.sql.Date(tuNgay.getTime()));
            cs.setDate(3, new java.sql.Date(denNgay.getTime()));
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    DonHang dh = new DonHang();
                    dh.setId(rs.getInt("id"));
                    dh.setThoiGianTao(rs.getTimestamp("thoiGianTao"));
                    dh.setTongTien(rs.getLong("tongTien"));
                    dh.setGiamGia(rs.getLong("giamGia"));
                    dh.setThanhTien(rs.getLong("thanhTien"));
                    dh.setPhuongThucTT(rs.getString("phuongThucTT"));
                    dh.setTrangThai("HoanThanh");
                    NhanVien nv = new NhanVien();
                    nv.setHoTen(rs.getString("thuNgan"));
                    dh.setThuNgan(nv);
                    String kh = rs.getString("khachHang");
                    if (kh != null) {
                        ThanhVien tv = new ThanhVien();
                        tv.setHoTen(kh);
                        dh.setKhachHang(tv);
                    }
                    kq.add(dh);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return kq;
    }

    /** Một đơn kèm chi tiết món và topping; null nếu không có. */
    public DonHang getChiTietDon(int idDonHang) {
        try (CallableStatement cs = con.prepareCall("{call sp_ChiTietDonHang(?)}")) {
            cs.setInt(1, idDonHang);
            boolean coKQ = cs.execute();
            if (!coKQ) {
                return null;
            }
            DonHang dh = null;
            try (ResultSet rs = cs.getResultSet()) {
                if (rs.next()) {
                    dh = new DonHang();
                    dh.setId(rs.getInt("id"));
                    dh.setThoiGianTao(rs.getTimestamp("thoiGianTao"));
                    dh.setTongTien(rs.getLong("tongTien"));
                    dh.setGiamGia(rs.getLong("giamGia"));
                    dh.setThanhTien(rs.getLong("thanhTien"));
                    dh.setPhuongThucTT(rs.getString("phuongThucTT"));
                    dh.setTienKhachDua(rs.getLong("tienKhachDua"));
                    dh.setTrangThai(rs.getString("trangThai"));
                    ChiNhanh cn = new ChiNhanh();
                    cn.setId(rs.getInt("idChiNhanh"));
                    cn.setMa(rs.getString("maCN"));
                    cn.setTen(rs.getString("tenCN"));
                    dh.setChiNhanh(cn);
                    NhanVien nv = new NhanVien();
                    nv.setHoTen(rs.getString("thuNgan"));
                    dh.setThuNgan(nv);
                    int idTV = rs.getInt("idThanhVien");
                    if (!rs.wasNull()) {
                        ThanhVien tv = new ThanhVien();
                        tv.setId(idTV);
                        tv.setHoTen(rs.getString("khachHang"));
                        tv.setSdt(rs.getString("sdtKhach"));
                        dh.setKhachHang(tv);
                    }
                    int idKM = rs.getInt("idKhuyenMai");
                    if (!rs.wasNull()) {
                        KhuyenMai km = new KhuyenMai();
                        km.setId(idKM);
                        km.setMaCode(rs.getString("maCode"));
                        dh.setKhuyenMai(km);
                    }
                }
            }
            if (dh == null) {
                return null;
            }
            Map<Integer, ChiTietDonHang> theoId = new HashMap<>();
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        SanPham sp = new SanPham();
                        sp.setTen(rs.getString("ten"));
                        KichCo kc = new KichCo();
                        kc.setMa(rs.getString("size"));
                        SanPhamKichCo spkc = new SanPhamKichCo();
                        spkc.setSanPham(sp);
                        spkc.setKichCo(kc);
                        spkc.setGia(rs.getLong("donGia"));
                        ChiTietDonHang ct = new ChiTietDonHang();
                        ct.setId(rs.getInt("id"));
                        ct.setSanPhamKichCo(spkc);
                        ct.setMucDuong(rs.getString("mucDuong"));
                        ct.setMucDa(rs.getString("mucDa"));
                        ct.setSoLuong(rs.getInt("soLuong"));
                        ct.setDonGia(rs.getLong("donGia"));
                        ct.setThanhTien(rs.getLong("thanhTien"));
                        dh.getDsChiTiet().add(ct);
                        theoId.put(ct.getId(), ct);
                    }
                }
            }
            if (cs.getMoreResults()) {
                try (ResultSet rs = cs.getResultSet()) {
                    while (rs.next()) {
                        ChiTietDonHang ct = theoId.get(rs.getInt("idChiTietDonHang"));
                        if (ct == null) continue;
                        Topping t = new Topping();
                        t.setId(rs.getInt("idTopping"));
                        t.setTen(rs.getString("ten"));
                        t.setGia(rs.getLong("donGia"));
                        ChiTietTopping ctt = new ChiTietTopping();
                        ctt.setTopping(t);
                        ctt.setSoLuong(rs.getInt("soLuong"));
                        ctt.setDonGia(rs.getLong("donGia"));
                        ct.getDsTopping().add(ctt);
                    }
                }
            }
            return dh;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    // ---------------- Pha chế ----------------

    /** Các đơn đang chờ hoặc đang pha chế của chi nhánh, cũ nhất trước. */
    public List<DonHang> getDSDonPhaChe(int idChiNhanh) {
        List<DonHang> kq = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call sp_DSDonPhaChe(?)}")) {
            cs.setInt(1, idChiNhanh);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    DonHang dh = new DonHang();
                    dh.setId(rs.getInt("id"));
                    dh.setThoiGianTao(rs.getTimestamp("thoiGianTao"));
                    dh.setTrangThai(rs.getString("trangThai"));
                    dh.setThanhTien(rs.getLong("thanhTien"));
                    NhanVien nv = new NhanVien();
                    nv.setHoTen(rs.getString("thuNgan"));
                    dh.setThuNgan(nv);
                    kq.add(dh);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return kq;
    }

    /** Chuyển trạng thái đơn (chỉ khi đơn đang ở trạng thái {@code tu}). */
    public boolean capNhatTrangThai(int idDonHang, int idChiNhanh, String tu, String den) {
        try (CallableStatement cs = con.prepareCall("{call sp_CapNhatTrangThaiDon(?,?,?,?)}")) {
            cs.setInt(1, idDonHang);
            cs.setInt(2, idChiNhanh);
            cs.setString(3, tu);
            cs.setString(4, den);
            try (ResultSet rs = cs.executeQuery()) {
                return rs.next() && rs.getInt("soDong") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
