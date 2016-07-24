![alt tag](https://raw.githubusercontent.com/edgardowardo/WindySky/master/icons/windy_sky%40launch.png)

# WindySky

Deployment Target : iOS 8.0

Using Swift 2.2 on Xcode 7.3.1

# Development Walkthrough 

Why realm? It is the fastest local datastore. City search scans at least 200K records on disk. So performance is important.

Why save city data on disk in the first place? Open weather map org recommends to query current data using city id to get unambiguous city result. This means storing city id's and name on disk. Search by name on the OpenWeather api is very ambiguous and does not return sensible results for example using "Xxx" returns a croatian city. It should return an error from the server. The word "Manchester" returns no list options and only returns the US city no option for the decadent English city.

Why Alamofire? There is an existing OpenWeatherMapAPI why not use it?  OpenWeatherMapAPI cocoa pod only provides JSON data without the direction codes and speed name, whilst the XML data returns more sensible wind info such as speed name, direction code which simplifies plotting of cardinal direction. As of time of writing OWM has discontinued responding with XML data. Another reason to use custom API is this API is 3 years old and may not be supported. A distinct set of needed API would be enough.

Why Charts? It's the best and easiest way to plot a radar chart.

There are no XCUI test because there is an issue in UISearchController result-set being voice-over in-accessible. Since XCUI is based on UI elements being voice over accessible, testing is impossible unless the whole search function is re-written by not using UISearchController. This holds true to Apple specific apps such as Mail that employs UISearchController. Even WhatsApp search bar results is voice over in-accessible and therefore XCUI un-testable! Functional tests are provided as described below.

Why MVVM (Model-View-ViewModel) pattern? This pattern forces development to create an extra layer (ViewModel) independent of UI frameworks. This makes this highly maintainable, since you know where exactly are the functional logic in the code, and not muddled within the MVC aka Massive-View-Controller. Another reason to use MVVM is that the ViewModel layer can easily be functionally tested. Having said this, there are five functional tests. Firstly testing SpotService which loads all spot data. Testing CitiesViewModel which queries the spots anywhere in the world by string, producing the cityid with an un-ambiguous result. And eventually querying asynchronously to the server to show more recent data and favourites. Testing CityViewModel asynchronously closely inspects end-to-end tests from when a spot is selected. Testing negative as well as positive result for the OpenWeatherMapService.

Why RxSwift? It's a nice implementation to functional reactive programming in Swift. The alternative is ReactiveCocoa. Although I am still a beginner, it is a powerful library for asynchronous programming with streams. I used this as the mechanism to implement the observer pattern between the presentation and view model layer. 
