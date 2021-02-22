# Snow Plow App
### By Michael Baraty and Kyle Hannibal
#### Open in XCode 10.1

Breakdown:
	Frontend:
		- Select customer/plow user
			- Customer:
				- Request service
					- Collect Location
					- Extra information
			- Plow User:
				- Recieve jobs
				- Format jobs for User
				- Must be able to tap on flags and see additional information
				- Accept jobs
				- Mark jobs as completed
	Backend:
		- Understand Parse API
		- Interfacing between frontend and backend
		- Database to store "flags"
			- Location (GPS)
			- Other Data
		- Functions must be capable of:
			- Can receive service requests
			- Can send list of nearby jobs to plow user
			- Can receive accepted jobs from plow user
			- Can recieve completed jobs

Stretch Goals:
	- Payment
	- Sign-in for app
	- Other properties for flags
		- "Need complete by", "Priority", "Payment"
	- Push notification upon acceptance/completion
		- When flags appear
	- Rating users both ways
	- Tips
	- Allowing plow-user to add extra information about clients, such as shape of driveway
