package model;

import java.io.Serializable;

/** Nhân viên; chucVu ∈ {ThuNgan, PhaChe, QuanLyCH, QuanLyChuoi}. */
public class NhanVien extends NguoiDung implements Serializable {

    private static final long serialVersionUID = 1L;

    private int idNhanVien;
    private String maNV;
    private String chucVu;
    private ChiNhanh chiNhanh;

    public NhanVien() {
    }

    public int getIdNhanVien() {
        return idNhanVien;
    }

    public void setIdNhanVien(int idNhanVien) {
        this.idNhanVien = idNhanVien;
    }

    public String getMaNV() {
        return maNV;
    }

    public void setMaNV(String maNV) {
        this.maNV = maNV;
    }

    public String getChucVu() {
        return chucVu;
    }

    public void setChucVu(String chucVu) {
        this.chucVu = chucVu;
    }

    public ChiNhanh getChiNhanh() {
        return chiNhanh;
    }

    public void setChiNhanh(ChiNhanh chiNhanh) {
        this.chiNhanh = chiNhanh;
    }

    public static final String THU_NGAN = "ThuNgan";
    public static final String PHA_CHE = "PhaChe";
    public static final String QUAN_LY_CH = "QuanLyCH";
    public static final String QUAN_LY_CHUOI = "QuanLyChuoi";

    public String getTenChucVu() {
        if (THU_NGAN.equals(chucVu)) return "Thu ngân";
        if (PHA_CHE.equals(chucVu)) return "Pha chế";
        if (QUAN_LY_CH.equals(chucVu)) return "Quản lý cửa hàng";
        if (QUAN_LY_CHUOI.equals(chucVu)) return "Quản lý chuỗi";
        return chucVu;
    }
}
