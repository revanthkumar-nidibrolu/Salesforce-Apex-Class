public class SendEmailQueueable implements Queueable{
    set<Id> oppIds;
    public SendEmailQueueable(set<id> oppIds){
        this.oppIds = oppIds;
    }
    public void execute (QueueableContext qc){
        List<Opportunity> oppList = [SELECT
                                    Id,
                                    Name,
                                    Owner.Email
                                    FROM Opportunity
                                    WHERE
                                    Id IN : oppIds];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp : oppList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Opportunity Closed Won');
            mail.setPlainTextBody('Congratulations! Opportunity ' + opp.Name + ' has been marked as Closed Won.');
            mail.setToAddresses(new List<String>{opp.Owner.Email});
            emails.add(mail);
        }
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}