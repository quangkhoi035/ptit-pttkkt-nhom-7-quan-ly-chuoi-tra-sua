package model;

import java.io.Serializable;
import java.util.Date;

/** Kết quả thống kê doanh thu của một chi nhánh (không lưu CSDL). */
public class TKChiNhanh extends ChiNhanh implements Serializable {

    private static final long serialVersionUID = 1L;

    private int soDon;
    private long doanhThu;
    private Date tuNgay;
    private Date denNgay;

    public TKChiNhanh() {
    }

    public int getSoDon() {
        return soDon;
    }

    public void setSoDon(int soDon) {
        this.soDon = soDon;
    }

    public long getDoanhThu() {
        return doanhThu;
    }

    public void setDoanhThu(long doanhThu) {
        this.doanhThu = doanhThu;
    }

    public Date getTuNgay() {
        return tuNgay;
    }

    public void setTuNgay(Date tuNgay) {
        this.tuNgay = tuNgay;
    }

    public Date getDenNgay() {
        return denNgay;
    }

    public void setDenNgay(Date denNgay) {
        this.denNgay = denNgay;
    }
}
