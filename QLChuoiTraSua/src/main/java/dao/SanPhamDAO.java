package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.DanhMuc;
import model.KichCo;
import model.SanPham;
import model.SanPhamKichCo;
import model.Topping;

public class SanPhamDAO extends DAO {

    /**
     * Thực đơn của một chi nhánh: mỗi sản phẩm kèm danh mục, trạng thái bán tại chi nhánh
     * và danh sách giá theo kích cỡ.
     */
    public List<SanPham> getMenuChiNhanh(String maCN) {
        Map<Integer, SanPham> map = new LinkedHashMap<>();
        Map<Integer, DanhMuc> dms = new LinkedHashMap<>();
        try (CallableStatement cs = con.prepareCall("{call sp_LayMenuChiNhanh(?)}")) {
            cs.setString(1, maCN);
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    int id = rs.getInt("id");
                    SanPham sp = map.get(id);
                    if (sp == null) {
                        sp = new SanPham();
                        sp.setId(id);
                        sp.setTen(rs.getString("ten"));
                        sp.setMoTa(rs.getString("moTa"));
                        sp.setHinhAnh(rs.getString("hinhAnh"));
                        sp.setTrangThai(true);
                        sp.setDangBan(rs.getBoolean("dangBan"));
                        int idDM = rs.getInt("idDanhMuc");
                        DanhMuc dm = dms.get(idDM);
                        if (dm == null) {
                            dm = new DanhMuc();
                            dm.setId(idDM);
                            dm.setTen(rs.getString("danhMuc"));
                            dms.put(idDM, dm);
                        }
                        sp.setDanhMuc(dm);
                        map.put(id, sp);
                    }
                    KichCo kc = new KichCo();
                    kc.setId(rs.getInt("idKichCo"));
                    kc.setMa(rs.getString("size"));
                    kc.setTen(rs.getString("tenSize"));
                    SanPhamKichCo g = new SanPhamKichCo();
                    g.setId(rs.getInt("idSPKC"));
                    g.setGia(rs.getLong("gia"));
                    g.setKichCo(kc);
                    g.setSanPham(sp);
                    sp.getDsGia().add(g);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return new ArrayList<>(map.values());
    }

    public List<Topping> getDSTopping() {
        List<Topping> kq = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call sp_LayDSTopping()}");
             ResultSet rs = cs.executeQuery()) {
            while (rs.next()) {
                Topping t = new Topping();
                t.setId(rs.getInt("id"));
                t.setTen(rs.getString("ten"));
                t.setGia(rs.getLong("gia"));
                t.setTrangThai(true);
                kq.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return kq;
    }
}
