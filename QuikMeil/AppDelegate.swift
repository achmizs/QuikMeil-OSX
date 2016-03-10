//
//  AppDelegate.swift
//  QuikMeil
//
//  Copyright 2016 Said Achmiz (www.saidachmiz.net)
//
//	This library is free software; you can redistribute it and/or modify it
//	under the terms of the GNU Lesser General Public License as published by
//	the Free Software Foundation; either version 2 of the License, or (at your
//	option) any later version.
//
//	This library is distributed in the hope that it will be useful, but WITHOUT
//	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//	FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
//	License for more details.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, QMConnectionManagerDelegate
{
	// *********************
	// MARK: - UI properties
	// *********************

	@IBOutlet weak var window: NSWindow!
	
	@IBOutlet weak var inputField: NSTextField!
	@IBOutlet weak var mainChatViewScrollView: NSScrollView!
	var mainChatView: NSTextView
	{
		get
		{
			return mainChatViewScrollView.contentView.documentView as! NSTextView
		}
	}
	
	var chatFont: NSFont?
	{
		get
		{
			return mainChatView.font
		}
	}
	
	@IBOutlet weak var serverField: NSTextField!
	@IBOutlet weak var portField: NSTextField!
	@IBOutlet weak var nickField: NSTextField!
	@IBOutlet weak var channelField: NSTextField!
	
	@IBOutlet weak var connectButton: NSButton!
	@IBOutlet weak var joinChannelButton: NSButtonCell!
	
	// ************************
	// MARK: - Other properties
	// ************************
	
	var session: IRCClientSession?
	var connectionManager: QMConnectionManager!
	
	var currentChannel: NSData?
	
	// **********************
	// MARK: - Action methods
	// **********************
	
	@IBAction func connectButtonPressed(sender: AnyObject)
	{
		print("Connect button pressed.")
		
		session = IRCClientSession()
		
		session!.delegate = connectionManager
		connectionManager.session = session
		
		let server = NSDataFromString(serverField.stringValue)
		let port = UInt(portField.integerValue)
		let nickname = NSDataFromString(nickField.stringValue)
		let username = NSDataFromString("nobormot")
		let realname = NSDataFromString("Nobormot")
		session!.server = server
		session!.port = port
		session!.setNickname(nickname, username: username, realname: realname)
		
		session!.connect()
		
		session!.run()
	}
	
	@IBAction func joinChannelButtonPressed(sender: AnyObject)
	{
		print("Join channel button pressed.")
		
		let channelName = NSDataFromString(channelField.stringValue)
		currentChannel = channelName
		session?.join(channelName, key: nil)
	}
	
	@IBAction func inputFieldEnterPressed(sender: AnyObject)
	{
		print("Input field enter pressed.")
		
		if inputField.stringValue != "" && session?.connected == true
		{
			if inputField.stringValue.hasPrefix("/raw")
			{
				connectionManager.sendRaw(inputField.stringValue.substringFromIndex(inputField.stringValue.startIndex.advancedBy(4)).stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: " \t")))
				
				inputField.stringValue = ""
			}
			else if let channelName = currentChannel
			{
				if inputField.stringValue.hasPrefix("/me")
				{
					connectionManager.sendAction(inputField.stringValue.substringFromIndex(inputField.stringValue.startIndex.advancedBy(3)).stringByTrimmingCharactersInSet(NSCharacterSet.init(charactersInString: " \t")), channel: channelName)
				}
				else
				{
					connectionManager.sendMessage(inputField.stringValue, channel: channelName)
				}
				
				inputField.stringValue = ""
			}
		}
	}
	
	// *********************
	// MARK: - Other methods
	// *********************
	
	func applicationDidFinishLaunching(aNotification: NSNotification)
	{
		connectionManager = QMConnectionManager()
		connectionManager.delegate = self
		
		mainChatView.font = NSFont.init(name: "Inconsolata", size: 16.0)
		inputField.font = NSFont.init(name: "Inconsolata", size: 16.0)
	}

	func applicationWillTerminate(aNotification: NSNotification)
	{
		// Insert code here to tear down your application
	}
	
	// ************************
	// MARK: - Delegate methods
	// ************************
	
	func connected()
	{
		connectButton.enabled = false
	}
	
	func channelJoined()
	{
		joinChannelButton.enabled = false
	}

	func displayLine(line: NSAttributedString)
	{
		mainChatView.textStorage?.beginEditing()
		mainChatView.textStorage?.appendAttributedString(line)
		mainChatView.textStorage?.endEditing()
		
		mainChatView.scrollToEndOfDocument(self)
		mainChatView.needsDisplay = true
	}
}

