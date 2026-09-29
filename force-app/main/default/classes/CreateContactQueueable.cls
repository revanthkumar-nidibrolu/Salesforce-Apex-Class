public class CreateContactQueueable implements Queueable{
    public void execute(QueueableContext qc){
        List<Account> accList = [SELECT
                                Id,
                                Name,
                                (SELECT
                                Id
                                FROM Contacts
                                LIMIT 1)
                                FROM Account
                                WHERE
                                Active__c = True];
        List<Contact> contactInsert = new List<Contact>();
        for(Account acc : accList){
            if(acc.Contacts.isEmpty()){
                contactInsert.add(new contact(
                LastName = acc.Name + ' Contact',
                AccountId = acc.Id));
            }
        }
        if(!contactInsert.isEmpty()){
            insert contactInsert;
        }
    }
}