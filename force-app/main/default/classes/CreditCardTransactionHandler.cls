public class CreditCardTransactionHandler {
    public static void crtLinkedCredirCardActive(List<Credit_Card_Transaction__c> newTrans){
        string customError = system.label.transactionNotCreateWithOutCardActive;
        String cardNumError = system.label.cardNumberMissMatch;
        set<Id> cardIds = new set<Id>();
        for(Credit_Card_Transaction__c crt : newTrans){
            if(crt.Credit_Card__c != Null){
                cardIds.add(crt.Credit_Card__c);
            }
        }
        Map<Id, Credit_Card__c> cardList = new Map<Id, Credit_Card__c>([SELECT
                                                                        Id,
                                                                        Status__c,
                                                                        Card_Number__c
                                                                        FROM Credit_Card__c
                                                                        WHERE Id IN : cardIds]);
        for(Credit_Card_Transaction__c crt : newTrans){
            Credit_Card__c card = cardList.get(crt.Credit_Card__c);
            if(card.Status__c != 'Active'){
                crt.addError(customError);
            }if(card.Card_Number__c != crt.Card_Number__c){
                crt.addError(cardNumError);
            }
        }
    }
    
    public static void updatingCCTAmount(List<Credit_Card_Transaction__c> newCCT){
        Map<Id, Decimal> transAmount = New Map<Id, Decimal>();
        for(Credit_Card_Transaction__c cct : newCCT){
            if(cct.Amount__c != Null){
                if(!transAmount.containsKey(cct.Credit_Card__c)){
                    transAmount.put(cct.Credit_card__c,0);
                }
                transAmount.put(cct.Credit_Card__c, transAmount.get(cct.Credit_Card__c) + cct.Amount__c);
            }
        }
        List<Credit_Card__c> cardLimitUpdate = [SELECT
                                               Id,
                                               Available_Limit__c
                                               FROM Credit_Card__c
                                               WHERE Id IN : transAmount.keyset()];
        for(Credit_Card__c card : cardLimitUpdate){
            card.Available_Limit__c = card.Available_Limit__c - transAmount.get(card.Id);
        }
        if(!cardLimitUpdate.isEmpty()){
            Update cardLimitUpdate;
        }
    }
    
    public static void AmountFieldCanNotEdit(List<Credit_Card_Transaction__c> cctList, Map<Id, Credit_Card_Transaction__c>oldMap){
        for(Credit_Card_Transaction__c cct : cctList){
            Credit_Card_Transaction__c oldCct = oldMap.get(cct.Id);
            if(cct.Amount__c != oldCct.Amount__c){
                cct.Amount__c.addError(system.label.amountCanNotChange);
            }
        }
    }
    
    public static void amountRefund(List<Credit_Card_Transaction__c> cctList, Map<Id, Credit_Card_Transaction__c>oldMap){
        set<Id> cardId = new set<Id>();
        List<Credit_Card__c> updateAmount = new List<Credit_Card__c>();
        for(Credit_Card_Transaction__c cct : cctList){
            Credit_Card_Transaction__c oldCct = oldMap.get(cct.Id);
            if(oldCct.Payment_Status__c == 'Success' && cct.Payment_Status__c == 'Refund'){
                cardId.add(cct.Credit_Card__c);
            }
        }
        Map<Id, Credit_Card__c> cardList = new Map<Id, Credit_Card__c>([SELECT
                                                                       Id,
                                                                       Total_Limit__c,
                                                                       Available_Limit__c
                                                                       FROM Credit_Card__c
                                                                       WHERE Id IN : cardId]);
        for(Credit_Card_Transaction__c cct : cctList){
            Credit_Card_Transaction__c oldCct = oldMap.get(cct.Id);
            if(oldCct.Payment_Status__c == 'Success' && cct.Payment_Status__c == 'Refund'){
                Credit_Card__c card = cardList.get(cct.Credit_Card__c);
                Decimal amountRefund = card.Available_Limit__c + cct.Amount__c;
                if(amountRefund > card.Total_Limit__c){
                    cct.addError(system.label.amountNotRefundOverLimit);
                }
                else{
                    card.Available_Limit__c = amountRefund;
                    updateAmount.add(card);
                }
            }
        }
        if(!updateAmount.isEmpty()){
            Update updateAmount;
        }
    }
    
    public static void statusMail(List<Credit_Card_Transaction__c> cctList){
        set<Id> ownerIds = new set<Id>();
        for(Credit_Card_Transaction__c cct : cctList){
            ownerIds.add(cct.OwnerId);
        }
        Id creditTemaplateId = '00XgL00000Ty0UH';
        Id debitTemaplateId = '00XgL00000Txytt';
        Map<Id, User> newMap = new Map<Id, User>([SELECT
                                                  Id,
                                                  Email
                                                  FROM User
                                                  WHERE Id IN : ownerIds]);
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Credit_Card_Transaction__c cct : cctList){
            User Owner = newMap.get(cct.OwnerId);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(owner.Id); 
            mail.setSaveAsActivity(false);
            if(cct.Payment_Status__c == 'Success'){
                mail.setTemplateId(debitTemaplateId);
                mails.add(mail);
            }
            else if(cct.Payment_Status__c == 'Refund'){
                mail.setTemplateId(creditTemaplateId);
                mails.add(mail);
            }
        }
        if(!mails.isEmpty()){
            Messaging.sendEmail(mails);
        }
    }
    
    public static void transactionDateUpdate(List<Credit_Card_Transaction__c> cctList, Map<Id, Credit_Card_Transaction__c> oldMap){
        for(Credit_Card_Transaction__c cct : cctList){
            if(oldMap == Null || oldMap != Null && cct.Payment_Status__c != oldMap.get(cct.Id).Payment_Status__c && 
               cct.Payment_Status__c == 'Success' || cct.Payment_Status__c == 'Refund'){
                cct.Transaction_Date__c = system.today();
            }	
        }
    }
}