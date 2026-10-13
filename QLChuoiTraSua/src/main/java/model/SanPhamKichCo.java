package model;

import java.io.Serializable;

/** Giá của một sản phẩm ở một kích cỡ. */
public class SanPhamKichCo implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private long gia;
    private SanPham sanPham;
    private KichCo kichCo;

    public SanPhamKichCo() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public long getGia() {
        return gia;
    }

    public void setGia(long gia) {
        this.gia = gia;
    }

    public SanPham getSanPham() {
        return sanPham;
    }

    public void setSanPham(SanPham sanPham) {
        this.sanPham = sanPham;
    }

    public KichCo getKichCo() {
        return kichCo;
    }

    public void setKichCo(KichCo kichCo) {
        this.kichCo = kichCo;
    }
}
