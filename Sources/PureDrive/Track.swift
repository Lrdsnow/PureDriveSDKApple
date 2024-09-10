//
//  Track.swift
//  PureDrive
//
//  Created by Lrdsnow on 8/24/24.
//

import Foundation

extension VehicleDelegate {
    
    public func scanTrack() -> [(String, Bool, Int)] {
        setSpeed(700, 700)
        
        var startFinishCount = 0
        var trackLog: [(String, Bool, Int)] = []
        var lastPos = -1
        
        loggedTracks.removeAll()
        
        while startFinishCount < 3 {
            if let lastTrack = loggedTracks.last, lastPos != lastTrack.2 {
                if startFinishCount == 1 {
                    trackLog.append(lastTrack)
                }
                if lastTrack.0 == "Start/Finish" {
                    print(startFinishCount)
                    startFinishCount += 1
                    if startFinishCount == 1 {
                        loggedTracks = []
                    }
                }
                if startFinishCount == 1,
                   lastTrack.0 == "Pre-Finish Line" {
                    setSpeed(0, 2800)
                    break
                }
                lastPos = lastTrack.2
            }
        }
        
        
        let finish_clockwise = trackLog.last?.1 ?? false
        trackLog = trackLog.filter({ $0.0 != "Start/Finish" && $0.0 != "Pre-Finish Line" })
        trackLog.append(("Pre-Finish Line", finish_clockwise, 0))
        trackLog.append(("Start/Finish", finish_clockwise, 0))
        
        let newTrackLog = filterDuplicates(from: trackLog)
        loggedTracks = newTrackLog
        return newTrackLog
    }
    
    // Function to filter out duplicates based on immediate successors
    func filterDuplicates(from readings: [(String, Bool, Int)]) -> [(String, Bool, Int)] {
        var filteredReadings: [(String, Bool, Int)] = []
        
        var i = 0
        while i < readings.count {
            let current = readings[i]
            let (currentType, _, currentPosition) = current
            
            // Append the current reading
            filteredReadings.append(current)
            
            // Check for immediate successors of the same type
            var j = i + 1
            var foundValidSuccessor = false
            while j < readings.count {
                let next = readings[j]
                let (nextType, _, nextPosition) = next
                
                if nextType == currentType {
                    if nextPosition >= currentPosition {
                        // Found a valid successor with a greater position
                        foundValidSuccessor = true
                        break
                    } else {
                        // Skip this duplicate
                        j += 1
                    }
                } else {
                    // Different track type; move to the next reading
                    break
                }
            }
            
            if !foundValidSuccessor {
                // If no valid successor was found, remove the current reading and retain the last valid one
                filteredReadings.removeLast()
                filteredReadings.append(current)
            }
            
            // Move to the next reading
            i = j
        }
        
        return filteredReadings
    }
}

