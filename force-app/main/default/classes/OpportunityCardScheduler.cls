public class OpportunityCardScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<Opportunity> opportunities = [SELECT Id,
                                                  Name,
                                                  Card_Text__c
                                             FROM Opportunity
                                            WHERE 
                                                  Card_Text__c != null];
        if (opportunities.isEmpty()) {
            return;
        }
        Set<String> textValues = new Set<String>();
        for (Opportunity opp : opportunities) {
            if (String.isNotBlank(opp.Card_Text__c)) {
                textValues.add(opp.Card_Text__c.trim());
            }
        }
        if (textValues.isEmpty()) {
            return;
        }
        List<Card__c> existingCards = [SELECT Id,
                                              Opportunity_Description__c
                                         FROM Card__c
                                        WHERE 
                                              Opportunity_Description__c IN :textValues];
        Set<String> existingValues = new Set<String>();
        for (Card__c card : existingCards) {
            if (String.isNotBlank(card.Opportunity_Description__c)) {
                existingValues.add(card.Opportunity_Description__c.trim());
            }
        }
        List<Card__c> cardsToCreate = new List<Card__c>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opp : opportunities) {
            if (String.isBlank(opp.Card_Text__c)) {
                continue;
            }
            
            String value = opp.Card_Text__c.trim();
            if(existingValues.contains(value)){
                continue;
            }
            Card__c newCard = new Card__c();
            newCard.Name = value;
            newCard.Opportunity_Description__c = value;
            newCard.Opportunity__c = opp.Id;
            cardsToCreate.add(newCard);
            existingValues.add(value);
            opp.Card_Text__c = null;
            opportunitiesToUpdate.add(opp);
        }
        if (!cardsToCreate.isEmpty()) {
            try{
                insert cardsToCreate;
            }catch(Exception e){
                System.debug('Exception Message: ' + e.getMessage());      
            }
        }
        if (!opportunitiesToUpdate.isEmpty()) {
            try{
                update opportunitiesToUpdate;
            }catch(Exception e){
                system.debug('Error: '+e.getMessage());
            }
        }
    }
}