/* public virtual class AccountDiscount {
    public virtual Decimal calculateDiscount(Decimal totalAmount){
        return totalAmount * 0.05;
    }
} */
public abstract class AccountDiscount {
    public abstract Decimal calculateDiscount(Decimal totalAmount);
}