public class DiscountPersentage{
    public decimal persenDiscount(Decimal totalAmount){
        return totalAmount * 0.05;
    }
    public Decimal persenDiscount(Account acc){
        if(acc.Type == 'Prospect'){
            return 0.20;
        }
        return 0.05;
    }
}