package pl.kolak.myfinance;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Objects;

@Document
public class PersistedPayment {
    private final String name;

    @Id
    private final String time;
    private final String amount;
    private final String paymentType;
    private final String paymentMethod;

    public PersistedPayment(String name, String time, String amount, String paymentType, String paymentMethod) {
        this.name = name;
        this.time = time;
        this.amount = amount;
        this.paymentType = paymentType;
        this.paymentMethod = paymentMethod;
    }

    public String getName() {
        return name;
    }

    public String getTime() {
        return time;
    }

    public String getAmount() {
        return amount;
    }

    public String getPaymentType() {
        return paymentType;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PersistedPayment payment = (PersistedPayment) o;

        String thisTime = time.split(" ")[0];
        String otherTime = payment.time.split(" ")[0];

        return Objects.equals(name, payment.name)
                && Objects.equals(thisTime, otherTime)
                && Objects.equals(amount, payment.amount)
                && Objects.equals(paymentType, payment.paymentType)
                && Objects.equals(paymentMethod, payment.paymentMethod);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, time, amount, paymentType, paymentMethod);
    }

    @Override
    public String toString() {
        return "PersistedPayment{" +
                "name='" + name + '\'' +
                ", time='" + time + '\'' +
                ", amount='" + amount + '\'' +
                ", paymentType='" + paymentType + '\'' +
                ", paymentMethod='" + paymentMethod + '\'' +
                '}';
    }
}
