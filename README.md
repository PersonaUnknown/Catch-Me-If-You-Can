# CSE438Final
 
Final Project
Catch Me If You Can! By Chan Lee, Daniel Ryu, Matthew Kim, Eric Tabuchi

Objective:
The seeker user will try to find the runner user before the time limit exceeds or the seeker user hits too many obstacles and dies.

How To Play:

Step 1. Sign up and Login
Sign up and login using id and password.

Step 2. Add friends
Click "View Friends" button which will lead to a tableview of all friends. Click "Add Friend" button and search for an existing user id that you want to friend request. Click "Invite" button to friend request that user. In order for a user to accept a friend request, click the envelop icon on the Welcome screen. This will lead to a new screen with all the friend requests received by the user and have buttons to accept or decline friend requests.

Step 3. Create New Game
If that user accepts your friend request, you can go back to the welcome screen and click on the "Make a New Game" button. This will lead to a new screen with all of your friends whom you can send a game request to. You will also have to set the time limit for the game to persist and the maximum number of obstacles the runner can put on the map. Then, click request on the user that you want to send game request to and press "Start Game" button. The person who starts game will become the runner and the person who receives game request will become seeker.

Step 4. Runner Point of View
As soon as the runner clicks the "Start Game" button, there will be a map displaying where the runner user is located, time left, and the number of obstacles left. The runner user will be able to click on the map to display obstacles on the map.

Step 5. Seeker Point of View
The person who will accept the game request will do so by first clicking the "Game Requests" button in the welcome screen. Then, there will be a tableview displaying all the game requests received with buttons to accept and decline those requests. As soon as the seeker clicks the accept button, the seeker user will see a new screen with the map showing where the seeker and runner users are currently at, time left, and the lives left as well. The seeker user has three lives; in other words, the game will end if the seeker hits the obstacles three times.

Step 6. Ending of the Game
If the time limit exceeds, then the app shows an alert message to runner and seeker users that the runner user won. If the seeker hits too many obstacles, then the app shows an alert message to runner and seeker users that the runner user won. If the seeker user catches runner user, then the app shows an alert message to runner and seeker users that the seeker won.
