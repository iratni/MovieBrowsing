//
//  MoviesViewController.swift
//  MovieBrowsing
//
//  Created by Youcef Iratni on 1/18/16.
//  Copyright © 2016 Youcef Iratni. All rights reserved.
//

import UIKit
import AFNetworking
import BXProgressHUD





class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var SearchBar: UISearchBar!
    
    
    var movies: [NSDictionary]?
    var lookedMovies: [NSDictionary]?
    var endpoint: String!
    
    var refreshControl = UIRefreshControl()
    
    // var selectionStyle: UITableViewCellSelectionStyle = .None
    // var backgroundView: UIView?
    
    var backgroundView = UIView()
    
    //    enum UITableViewCellSelectionStyle : Int {
    //        case None
    //        case Blue
    //        case Gray
    //        case Default
    //    }
    
    
//    var smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageUrl)!)
//    var largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageUrl)!)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SearchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        var targetView: UIView {
            return self.view
        }
        
        
        self.refreshControl = UIRefreshControl()
         refreshControl.addTarget(self, action: "refreshControlAction", forControlEvents: UIControlEvents.ValueChanged)
       // tableView.insertSubview(refreshControl, atIndex: 0)
        self.tableView.addSubview(self.refreshControl)
        self.refreshControl.backgroundColor = UIColor.lightGrayColor()
        self.refreshControl.tintColor = UIColor.redColor()
        
        print("\(endpoint)")
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        BXProgressHUD.showHUDAddedTo(targetView).hide(afterDelay: 3)
        
        
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.lookedMovies = self.movies
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                            
                    }
                }
        });
        task.resume()
        
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        view.addGestureRecognizer(tap)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = lookedMovies{
            return movies.count
        } else {
            return 0
        }
    }
    
    func refreshControlAction(){
       // delay(2, closure:{
            self.refreshControl.endRefreshing()
      //  })
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = lookedMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        
       // cell.selectionStyle = .None
        // let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.yellowColor()
        cell.selectedBackgroundView = backgroundView
        
        

        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        if let posterPath = movie["poster_path"] as? String {
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
       
        cell.posterView.setImageWithURL(imageUrl!)
            

        }
        
        //  cell.textLabel!.text = title
        print("row \(indexPath.row)")
        return cell
    }
//  
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select row")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        view.endEditing(true)
    }
    
    
//    
//    func dismissKeyboard() {
//        view.endEditing(true)
//    }
    
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            lookedMovies = movies
        } else {
            lookedMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        
                        return  true
                    } else {
                        return false
                    }
                }
                return false
            })
        }
        tableView.reloadData()
    }
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = lookedMovies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
