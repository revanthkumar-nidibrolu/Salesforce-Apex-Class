public class PositionHandler {
    public static void minMaxDate(List<Position__c> posMinMaxDate){
        for(Position__c pos : posMinMaxDate){
            if(pos.Status__c == 'New Position' && pos.Minimum_Pay__c == Null &&
               pos.Maximum_Pay__c == Null && pos.Open_Date__c == Null){
                   pos.Minimum_Pay__c = 400000;
                   pos.Maximum_Pay__c = 800000;
                   pos.Open_Date__c = System.today();
               }
            else if(pos.Status__c == 'UpComing Positions' && pos.Minimum_Pay__c == Null &&
                    pos.Maximum_Pay__c == Null){
                        pos.Minimum_Pay__c = 1200000;
                        pos.Maximum_Pay__c = 2400000;
              }
        }
    }
    public static void updateMinMaxDate(List<Position__c> posUpdateMinMaxDate, Map<Id, Position__c> oldMap){
        for(Position__c poss : posUpdateMinMaxDate){
            if(oldMap == Null && oldMap.get(poss.Id).Status__c == 'UpComing Positions' && 
               poss.Minimum_Pay__c == Null && poss.Maximum_Pay__c == Null){
                   poss.Minimum_Pay__c = 1200000;
                   poss.Maximum_Pay__c = 2400000;
               }
        }
    }
}