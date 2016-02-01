//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Joanna Meyer on 1/5/16.
//  Copyright © 2016 codepath. All rights reserved.
//



import MBProgressHUD
import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource,UISearchBarDelegate{
    

    @IBOutlet weak var NetworkErrorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    var movies: [NSDictionary]?
    var hud: MBProgressHUD?
    var filteredMovies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize a UIRefreshControl
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,action:"refreshAction:", forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.insertSubview(refreshControl, atIndex: 0) //Showing the refresh view
        

        tableView.dataSource = self
        searchBar.delegate = self
        
        //show HUD
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        // Do any additional setup after loading the view.
        networkCall()
    }
    
    func networkCall(){
    
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            print("response: \(responseDictionary)")
                        //hide HUD
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            
                            self.filteredMovies = self.movies!
                            
                            
                            self.tableView.reloadData()
                            
                    }
                    
                }else{
                    //There's a network error
                    print("There is a network error")
                    self.NetworkErrorView.hidden = true
                    
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                
        });
        task.resume()
        
        
        
        
        
        
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)
        
        
        print("row \(indexPath.row)")
        return cell
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func refreshAction(refreshControl: UIRefreshControl){
    networkCall()
    refreshControl.endRefreshing()
    }

    func refreshAction(){
        
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText:String){
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies!.filter({ (movie: NSDictionary) -> Bool in
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
    
    

}

