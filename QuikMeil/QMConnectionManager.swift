//
//  QMConnectionManager.swift
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

// ************************
// MARK: Useful functions
// ************************

func NSDataFromString(aString: String, withEncoding encoding: NSStringEncoding = NSUTF8StringEncoding) -> NSData
{
	return NSData.init(bytes: aString.cStringUsingEncoding(encoding)!,
		length: Int(strlen(aString.cStringUsingEncoding(encoding)!) + 1))
}

// ********************************************
// MARK: - QMConnectionManagerDelegate protocol
// ********************************************

protocol QMConnectionManagerDelegate
{
	var chatFont: NSFont? { get }
	
	func connected()
	func channelJoined()
	func displayLine(line: NSAttributedString)
}

// *********************************
// MARK: - QMConnectionManager class
// *********************************

class QMConnectionManager : NSObject, IRCClientSessionDelegate, IRCClientChannelDelegate
{
	// ******************
	// MARK: - Properties
	// ******************
	
	var delegate: QMConnectionManagerDelegate!
	
	weak var session: IRCClientSession!
	
	// ***************
	// MARK: - Methods
	// ***************
	
	func sendRaw(rawString: String)
	{
		// Construct the new chat line.
		let chatTextAttributes_PLAIN = [NSFontAttributeName : delegate.chatFont!]
		let chatTextAttributes_BLUE = [NSFontAttributeName : delegate.chatFont!, NSForegroundColorAttributeName : NSColor.blueColor()]
		
		let newChatLine = NSMutableAttributedString()
		newChatLine.appendAttributedString(NSAttributedString.init(string: "\n", attributes: chatTextAttributes_PLAIN))
		newChatLine.appendAttributedString(NSAttributedString.init(string: "\tSENT: ", attributes: chatTextAttributes_BLUE))
		newChatLine.appendAttributedString(NSAttributedString.init(string: rawString, attributes: chatTextAttributes_BLUE))
		
		// Display the line.
		delegate.displayLine(newChatLine)
		
		// Send the raw message.
		let raw = NSDataFromString(rawString)
		session.sendRaw(raw)
	}
	
	func sendMessage(messageString: String, channel channelName: NSData)
	{
		let nickString = String.init(data: session.nickname, encoding: session.encoding)
		
		// Construct the new chat line.
		let fontManager = NSFontManager.sharedFontManager()
		let chatTextAttributes_PLAIN = [NSFontAttributeName : delegate.chatFont!]
		let chatTextAttributes_BOLD = [NSFontAttributeName : fontManager.convertFont(delegate.chatFont!, toHaveTrait: NSFontTraitMask.BoldFontMask)]
		
		let newChatLine = NSMutableAttributedString()
		newChatLine.appendAttributedString(NSAttributedString.init(string: "\n", attributes: chatTextAttributes_PLAIN))
		newChatLine.appendAttributedString(NSAttributedString.init(string: nickString!, attributes: chatTextAttributes_BOLD))
		newChatLine.appendAttributedString(NSAttributedString.init(string: ": ", attributes: chatTextAttributes_BOLD))
		newChatLine.appendAttributedString(NSAttributedString.init(string: messageString, attributes: chatTextAttributes_PLAIN))
		
		// Display the line.
		delegate.displayLine(newChatLine)
		
		// Send the message.
		let message = NSDataFromString(messageString)
		let channel = session.channels[channelName] as! IRCClientChannel
		channel.message(message)
	}
	
	func sendAction(actionString: String, channel channelName: NSData)
	{
		let nickString = String.init(data: session.nickname, encoding: session.encoding)
		
		// Construct the new chat line.
		let fontManager = NSFontManager.sharedFontManager()
		let chatTextAttributes_PLAIN = [NSFontAttributeName : delegate.chatFont!]
		let chatTextAttributes_BOLD = [NSFontAttributeName : fontManager.convertFont(delegate.chatFont!, toHaveTrait: NSFontTraitMask.BoldFontMask)]
		
		let newChatLine = NSMutableAttributedString()
		newChatLine.appendAttributedString(NSAttributedString.init(string: "\n\t *", attributes: chatTextAttributes_PLAIN))
		newChatLine.appendAttributedString(NSAttributedString.init(string: nickString!, attributes: chatTextAttributes_BOLD))
		newChatLine.appendAttributedString(NSAttributedString.init(string: " ", attributes: chatTextAttributes_BOLD))
		newChatLine.appendAttributedString(NSAttributedString.init(string: actionString, attributes: chatTextAttributes_PLAIN))
		
		// Display the line.
		delegate.displayLine(newChatLine)
		
		// Send the action.
		let action = NSDataFromString(actionString)
		let channel = session.channels[channelName] as! IRCClientChannel
		channel.action(action)
	}
	
	// ****************************************
	// MARK: - IRCClientSessionDelegate methods
	// ****************************************
	
	func connectionSucceeded(sender: IRCClientSession!)
	{
		print("Connection succeeded.")
		delegate.connected()
	}
	
	func nickChangedFrom(oldNick: NSData!, to newNick: NSData!, own wasItUs: Bool, session sender: IRCClientSession!)
	{
		print("Nick changed from \(String(data: oldNick, encoding: session.encoding)) to \(String(data: newNick, encoding: session.encoding))")
	}
	
	func userQuit(nick: NSData!, withReason reason: NSData!, session sender: IRCClientSession!)
	{
		print("User \(String(data: nick, encoding: session.encoding)) quit with reason: \(String(data: reason, encoding: session.encoding)).")
	}
	
	func joinedNewChannel(channel: IRCClientChannel!, session sender: IRCClientSession!)
	{
		print("Joined channel \(String(data: channel.name, encoding: session.encoding)!).")
		
		channel.delegate = self
		delegate.channelJoined()
	}
	
	func modeSet(mode: NSData!, by nick: NSData!, session sender: IRCClientSession!)
	{
		print("Mode \(mode) set by \(nick).")
	}
	
	func privateMessageReceived(message: NSData!, fromUser nick: NSData!, session sender: IRCClientSession!)
	{
		print("Private message received.")
	}
	
	func privateNoticeReceived(notice: NSData!, fromUser nick: NSData!, session sender: IRCClientSession!)
	{
		print("Private notice received.")
	}
	
	func serverMessageReceivedFrom(origin: NSData!, params: [AnyObject]!, session sender: IRCClientSession!)
	{
		
	}
	
	func serverNoticeReceivedFrom(origin: NSData!, params: [AnyObject]!, session sender: IRCClientSession!)
	{
		
	}
	
	func invitedToChannel(channelName: NSData!, by nick: NSData!, session sender: IRCClientSession!)
	{
		
	}
	
	func privateCTCPActionReceived(action: NSData!, fromUser nick: NSData!, session sender: IRCClientSession!)
	{
		
	}
	
	// ****************************************
	// MARK: - IRCClientChannelDelegate methods
	// ****************************************
	
	func userJoined(nick: NSData!, channel sender: IRCClientChannel!)
	{
		
	}
	
	func userParted(nick: NSData!, channel sender: IRCClientChannel!, withReason reason: NSData!, us wasItUs: Bool)
	{
		
	}
	
	func modeSet(mode: NSData!, forChannel sender: IRCClientChannel!, withParams params: NSData!, by nick: NSData!)
	{
		
	}
	
	func topicSet(topic: NSData!, forChannel sender: IRCClientChannel!, by nick: NSData!)
	{
		
	}
	
	func userKicked(nick: NSData!, fromChannel sender: IRCClientChannel!, withReason reason: NSData!, by byNick: NSData!, us wasItUs: Bool)
	{
		
	}
	
	func messageSent(message: NSData!, byUser nick: NSData!, onChannel sender: IRCClientChannel!)
	{
		// Log the event to the console.
		let messageString = String(data: message, encoding: sender.encoding)!
		let nickString = String(data: nick, encoding: sender.encoding)!
		print("EVENT: messageSent:{\(messageString)} byUser:{\(nickString)}")
		
		let nickOnlyString = String(data: getNickFromNickUserHost(nick), encoding: sender.encoding)!
		
		// Construct the new chat line.
		let fontManager = NSFontManager.sharedFontManager()
		let chatTextAttributes_PLAIN = [NSFontAttributeName : delegate.chatFont!]
		let chatTextAttributes_BOLD = [NSFontAttributeName : fontManager.convertFont(delegate.chatFont!, toHaveTrait: NSFontTraitMask.BoldFontMask)]
		
		let newChatLine = NSMutableAttributedString()
		newChatLine.appendAttributedString(NSAttributedString.init(string: "\n", attributes: chatTextAttributes_PLAIN))
		newChatLine.appendAttributedString(NSAttributedString.init(string: nickOnlyString, attributes: chatTextAttributes_BOLD))
		newChatLine.appendAttributedString(NSAttributedString.init(string: ": ", attributes: chatTextAttributes_BOLD))
		newChatLine.appendAttributedString(NSAttributedString.init(string: messageString, attributes: chatTextAttributes_PLAIN))
		
		// Display the line.
		dispatch_async(dispatch_get_main_queue(), {
			self.delegate.displayLine(newChatLine)
		});
	}
	
	func noticeSent(notice: NSData!, byUser nick: NSData!, onChannel sender: IRCClientChannel!)
	{
		
	}
	
	func actionPerformed(action: NSData!, byUser nick: NSData!, onChannel sender: IRCClientChannel!)
	{
		
	}
}