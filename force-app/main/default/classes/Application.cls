public class Application {
	
	// Configure and create the UnitOfWorkFactory for this Application
	public static final fflib_Application.UnitOfWorkFactory UnitOfWork = new fflib_Application.UnitOfWorkFactory(
		new List<SObjectType> {
			Account.SObjectType
		});	

	// Configure and create the ServiceFactory for this Application
	public static final fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory( 
		new Map<Type, Type> {
			IUserService.class => UserService.class,
			IAccountService.class => AccountService.class,
			IOrderService.class => OrderService.class 
		});

	// Configure and create the SelectorFactory for this Application
	public static final fflib_Application.SelectorFactory Selector = new fflib_Application.SelectorFactory(
		new Map<SObjectType, Type> {
			Order.SObjectType => OrderSelector.class,
			User.SObjectType => UserSelector.class,
			Account.SObjectType => AccountSelector.class 
		});

	// Configure and create the DomainFactory for this Application
	public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory( Application.Selector,
		new Map<SObjectType, Type> {
			Order.SObjectType => OrderDomain.Constructor.class,
			Account.SObjectType => AccountDomain.Constructor.class 
		});

}