public without sharing class Schedule_AccountUpdateSalesRevenue implements Schedulable {
    public void execute(SchedulableContext sc) {

        // Lancer le batch avec des lots de 200 enregistrements
        Database.executeBatch(new BatchAccountUpdateSalesRevenue(), 200);

    }
}