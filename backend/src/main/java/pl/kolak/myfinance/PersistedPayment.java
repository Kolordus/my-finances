package pl.kolak.myfinance;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

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
