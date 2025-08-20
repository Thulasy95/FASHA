@isTest
public class TestDataFactory {

    public static List<Order> createOrdersWithOrderItems (Integer numOrders, ID accountID, String orderStatus, Integer shipmentCost, Integer numOrderItems, Id ownerId){

        // Pricebook standard obligatoire
        Id standardPbId = Test.getStandardPricebookId();
        
        // Création des Orders en Draft
        List<Order> newOrders = new List<Order>();
        for (Integer i = 0; i < numOrders; i++ ) {
            Order newOrder = new Order(
                AccountId = accountID,
                EffectiveDate = Date.today(),
                Status = 'Draft', // statut valide pour l'insertion
                ShipmentCost__c = shipmentCost,
                Pricebook2Id = standardPbId,
                OwnerId = ownerId
            ); 
            newOrders.add(newOrder);
        }
        insert newOrders;
        
        // Création du produit et du PricebookEntry
        // Un OrderItem doit être lié à un PricebookEntry (et donc à un Pricebook & Product)
        // On crée donc 1 produit et 1 PricebookEntry de test pour tous les items
        Product2 prod = new Product2(Name = 'TestProduct', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;

        // Création des OrderItems
        List<OrderItem> newOrderItems = new List<OrderItem>();
        for (Order newOrder : newOrders) {
            for (Integer j = 0; j < numOrderItems; j++) {
                OrderItem newOrderItem = new OrderItem(
                    OrderId = newOrder.Id,
                    UnitPrice = pbe.UnitPrice,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1
                );
                newOrderItems.add(newOrderItem); 
            }
        }
        insert newOrderItems;

        // Mise à jour du statut si nécessaire (après avoir au moins 1 OrderItem)
        if(orderStatus != 'Draft') {
            for(Order o : newOrders){
                o.Status = orderStatus;
            }
            update newOrders;
        }

        return newOrders; 

    }
    
    // Crée un utilisateur, avec option de passer un rôle existant
    public static User createUser(String alias, String username, String userRoleName, UserRole existingRole) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        UserRole roleToUse;
        if (existingRole != null) {
            roleToUse = existingRole;
        } else {
            roleToUse = new UserRole(Name = userRoleName);
            insert roleToUse;
        }

        User u = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = alias,
            Email = username + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            ProfileId = p.Id,
            UserName = username + '.' + System.currentTimeMillis() + '@test.com',
            UserRoleId = roleToUse.Id,
            IsActive = true
        );
        insert u;
        return u;
    }

    public static User createInactiveUser(String alias, String username, String userRoleName, UserRole existingRole) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        UserRole roleToUse;
        if (existingRole != null) {
            roleToUse = existingRole;
        } else {
            roleToUse = new UserRole(Name = userRoleName);
            insert roleToUse;
        }

        User u = new User(
            FirstName = 'Inactive',
            LastName = 'User',
            Alias = alias,
            Email = username + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Paris',
            ProfileId = p.Id,
            UserName = username + '.' + System.currentTimeMillis() + '@test.com',
            UserRoleId = roleToUse.Id,
            IsActive = false
        );
        insert u;
        return u;
    }

    // Crée une liste de comptes
    public static List<Account> createAccounts(Integer count) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < count; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i
            ));
        }
        return accounts;
    }
}
