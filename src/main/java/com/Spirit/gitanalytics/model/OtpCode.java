package com.Spirit.gitanalytics.model;

import java.sql.Timestamp;

/**
 * OtpCode - Mã OTP cho register / forgot password.
 */
public class OtpCode {
    private int otpId;
    private String target;     // email or phone
    private String purpose;    // REGISTER / FORGOT
    private String code;
    private Timestamp expiresAt;
    private boolean used;
    private Timestamp createdAt;

    public OtpCode() {}

    public int getOtpId() { return otpId; }
    public void setOtpId(int otpId) { this.otpId = otpId; }

    public String getTarget() { return target; }
    public void setTarget(String target) { this.target = target; }

    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public Timestamp getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Timestamp expiresAt) { this.expiresAt = expiresAt; }

    public boolean isUsed() { return used; }
    public void setUsed(boolean used) { this.used = used; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
