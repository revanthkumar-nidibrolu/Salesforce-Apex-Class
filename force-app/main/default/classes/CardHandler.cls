public class CardHandler {
    public static void duplicatesCards(List<Card__c> cardList){
        set<string> combineValue = new set<string>(); 
        for(Card__c cad : cardList){
            if(cad.Compare_Field__c != null){
                combineValue.add(cad.Compare_Field__c);
            }
        }
        Map<String, Id> existingCardMap = new Map<String, Id>();
        List<Card__c> existingCards = cards(combineValue);
        for(Card__c cad : existingCards){
            existingCardMap.put(cad.Compare_Field__c, cad.Id);
        }
        for(Card__c ncad : cardList){
            if(ncad.Compare_Field__c != null && existingCardMap.containsKey(ncad.Compare_Field__c)){
                if(ncad.Id != existingCardMap.get(ncad.Compare_Field__c)){
                    ncad.addError('Duplicate Card. This Compare Field already exists.');
                }
            }
        }
    }
    
    private static List<Card__c> cards (set<string> combineValue){
        return [SELECT Id,
                       Tier__c,
                       Type__c,
                       Active__c,
                       Compare_Field__c
                 FROM Card__c
                WHERE
                      Compare_Field__c IN : combineValue];
    }
    
    public static void fieldUpdate(List<Card__c> newCard){
        for(Card__c cad : newCard){
            cad.Compare_Field__c = 
                String.valueOf(cad.Active__c) + ' - ' + 
                String.valueOf(cad.Tier__c) + ' - ' + 
                String.valueOf(cad.Type__c);        
        }
    }
}