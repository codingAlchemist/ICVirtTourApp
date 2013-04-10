//
//  VirtTourSettingsViewController.m
//  ICVirtCampusTour
//
//  Created by Adeesha on 4/6/13.
//  Copyright (c) 2013 IC. All rights reserved.
//

#import "VirtTourSettingsViewController.h"

@interface VirtTourSettingsViewController ()

@end

@implementation VirtTourSettingsViewController

//connected programatically.
-(IBAction)changeMapType:(UISegmentedControl*)sender
{
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [_delegate setMapType:MKMapTypeStandard];
            break;
            
        case 1:
            [_delegate setMapType:MKMapTypeSatellite];
            break;
            
        default:
            [_delegate setMapType:MKMapTypeHybrid];
            break;
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Map type";
    else
        return @"Layers";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else
        return [_typesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"mapType";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        if (indexPath.row == 0)
        {
        //add the IBAction
        UISegmentedControl* setMapTypeControl = (UISegmentedControl*)[cell viewWithTag:1];
        
        //select the correct segment
            NSInteger currentElement;
            switch ([_delegate.theMapView mapType])
            {
                case MKMapTypeStandard:
                    currentElement = 0;
                    break;
                    
                case MKMapTypeSatellite:
                    currentElement = 1;
                    break;
                    
                default:
                    currentElement = 2;
                    break;
            }
            
            //select it
            [setMapTypeControl setSelectedSegmentIndex:currentElement];
        }
    }
    
    else
    {
        static NSString *CellIdentifier = @"layerCheck";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        //set the label of the cell
        UILabel* layerLabel = (UILabel*) [cell viewWithTag:0];
        [layerLabel setText:[_typesArray objectAtIndex:indexPath.row]];
    
    }
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
