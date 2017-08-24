//
//  Recorder.swift
//  BeKindRewind
//
//  Created by Jordan Zucker on 8/24/17.
//

import Foundation

public class Recorder: NSObject {

}

extension Recorder: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        print("\(#function) => session: \(session.debugDescription), task: \(task.debugDescription), metrics: \(metrics.debugDescription)")
    }
    
}
