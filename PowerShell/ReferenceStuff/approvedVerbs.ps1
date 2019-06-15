Common Verbs
PowerShell uses the System.Management.Automation.VerbsCommon enumeration class to define generic actions that can apply to almost any cmdlet. The following table lists most of the defined verbs.
Verb (alias)	Action	Comments
Add (a)
Adds a resource to a container, or attaches an item to another item. For example, the Add-Content cmdlet adds content to a file. This verb is paired with Remove.	For this action, do not use verbs such as Append, Attach, Concatenate, or Insert.
Clear (cl)
Removes all the resources from a container but does not delete the container. For example, the Clear-Content cmdlet removes the contents of a file but does not delete the file.	For this action, do not use verbs such as Flush, Erase, Release, Unmark, Unset, or Nullify.
Close (cs)
Changes the state of a resource to make it inaccessible, unavailable, or unusable. This verb is paired with Open.	
Copy (cp)
Copies a resource to another name or to another container. For example, the Copy-Item cmdlet that is used to access stored data copies an item from one location in the data store to another location.	For this action, do not use verbs such as Duplicate, Clone, Replicate, or Sync.
Enter (et)
Specifies an action that allows the user to move into a resource. For example, the Enter-PSSession cmdlet places the user in an interactive session. This verb is paired with Exit.	For this action, do not use verbs such as Push or Into.
Exit (ex)
Sets the current environment or context to the most recently used context. For example, the Exit-PSSession cmdlet places the user in the session that was used to start the interactive session. This verb is paired with Enter.	For this action, do not use verbs such as Pop or Out.
Find (fd)
Looks for an object in a container that is unknown, implied, optional, or specified.	
Format (f)	Arranges objects in a specified form or layout.	
Get (g)
Specifies an action that retrieves a resource. This verb is paired with Set.	For this action, do not use verbs such as Read, Open, Cat, Type, Dir, Obtain, Dump, Acquire, Examine, Find, or Search.
Hide (h)
Makes a resource undetectable. For example, a cmdlet whose name includes the Hide verb might conceal a service from a user. This verb is paired with Show.	For this action, do not use a verb such as Block.
Join (j)
Combines resources into one resource. For example, the Join-Path cmdlet combines a path with one of its child paths to create a single path. This verb is paired with Split.	For this action, do not use verbs such as Combine, Unite, Connect, or Associate.
Lock (lk)
Secures a resource. This verb is paired with Unlock.	For this action, do not use verbs such as Restrict or Secure.
Move (m)
Moves a resource from one location to another. For example, the Move-Item cmdlet moves an item from one location in the data store to another location.	For this action, do not use verbs such as Transfer, Name, or Migrate.
New (n)
Creates a resource. (The Set verb can also be used when creating a resource that includes data, such as the Set-Variable cmdlet.)	For this action, do not use verbs such as Create, Generate, Build, Make, or Allocate.
Open (op)
Changes the state of a resource to make it accessible, available, or usable. This verb is paired with Close.	
Optimize (om)	Increases the effectiveness of a resource.	
Pop (pop)
Removes an item from the top of a stack. For example, the Pop-Location cmdlet changes the current location to the location that was most recently pushed onto the stack.	
Push (pu)
Adds an item to the top of a stack. For example, the Push-Location cmdlet pushes the current location onto the stack.	
Redo (re)
Resets a resource to the state that was undone.	
Remove (r)	Deletes a resource from a container. For example, the Remove-Variable cmdlet deletes a variable and its value. This verb is paired with Add.	For this action, do not use verbs such as Clear, Cut, Dispose, Discard, or Erase.
Rename (rn)	Changes the name of a resource. For example, the Rename-Item cmdlet, which is used to access stored data, changes the name of an item in the data store.	For this action, do not use a verb such as Change.
Reset (rs)
Sets a resource back to its original state.	
Search (sr)	Creates a reference to a resource in a container.	For this action, do not use verbs such as Find or Locate.
Select (sc)	Locates a resource in a container. For example, the Select-String cmdlet finds text in strings and files.	For this action, do not use verbs such as Find or Locate.
Set (s)
Replaces data on an existing resource or creates a resource that contains some data. For example, the Set-Date cmdlet changes the system time on the local computer. (The New verb can also be used to create a resource.) This verb is paired with Get.	For this action, do not use verbs such as Write, Reset, Assign, or Configure.
Show (sh)
Makes a resource visible to the user. This verb is paired with Hide.	For this action, do not use verbs such as Display or Produce.
Skip (sk)
Bypasses one or more resources or points in a sequence.	For this action, do not use a verb such as Bypass or Jump.
Split (sl)
Separates parts of a resource. For example, the Split-Path cmdlet returns different parts of a path. This verb is paired with Join.	For this action, do not use a verb such Separate.
Step (st)
Moves to the next point or resource in a sequence.	
Switch (sw)	Specifies an action that alternates between two resources, such as to change between two locations, responsibilities, or states.	
Undo (un)	Sets a resource to its previous state.	
Unlock (uk)	Releases a resource that was locked. This verb is paired with Lock.	For this action, do not use verbs such as Release, Unrestrict, or Unsecure.
Watch (wc)	Continually inspects or monitors a resource for changes.	
Communications Verbs
PowerShell uses the System.Management.Automation.VerbsCommunications class to define actions that apply to communications. The following table lists most of the defined verbs.
Verb (alias)	Action	Comments
Connect (cc)
Creates a link between a source and a destination. This verb is paired with Disconnect.	For this action, do not use verbs such as Join or Telnet.
Disconnect (dc)	Breaks the link between a source and a destination. This verb is paired with Connect.	For this action, do not use verbs such as Break or Logoff.
Read (rd)
Acquires information from a source. This verb is paired with Write.	For this action, do not use verbs such as Acquire, Prompt, or Get.
Receive (rc)
Accepts information sent from a source. This verb is paired with Send.	For this action, do not use verbs such as Read, Accept, or Peek.
Send (sd)
Delivers information to a destination. This verb is paired with Receive.	For this action, do not use verbs such as Put, Broadcast, Mail, or Fax.
Write (wr)
Adds information to a target. This verb is paired with Read.	For this action, do not use verbs such as Put or Print.
Data Verbs
PowerShell uses the System.Management.Automation.VerbsData class to define actions that apply to data handling. The following table lists most of the defined verbs.
Verb Name (alias)	Action	Comments
Backup (ba)
Stores data by replicating it.	For this action, do not use verbs such as Save, Burn, Replicate, or Sync.
Checkpoint (ch)	Creates a snapshot of the current state of the data or of its configuration.	For this action, do not use a verb such as Diff.
Compare (cr)
Evaluates the data from one resource against the data from another resource.	For this action, do not use a verb such as Diff.
Compress (cm)	Compacts the data of a resource. Pairs with Expand.	For this action, do not use a verb such as Compact.
Convert (cv)
Changes the data from one representation to another when the cmdlet supports bidirectional conversion or when the cmdlet supports conversion between multiple data types.	For this action, do not use verbs such as Change, Resize, or Resample.
ConvertFrom (cf)	Converts one primary type of input (the cmdlet noun indicates the input) to one or more supported output types.	For this action, do not use verbs such as Export, Output, or Out.
ConvertTo (ct)	Converts from one or more types of input to a primary output type (the cmdlet noun indicates the output type).	For this action, do not use verbs such as Import, Input, or In.
Dismount (dm)	Detaches a named entity from a location. This verb is paired with Mount.	For this action, do not use verbs such as Unmount or Unlink.
Edit (ed)
Modifies existing data by adding or removing content.	For this action, do not use verbs such as Change, Update, or Modify.
Expand (en)
Restores the data of a resource that has been compressed to its original state. This verb is paired with Compress.	For this action, do not use verbs such as Explode or Uncompress.
Export (ep)
Encapsulates the primary input into a persistent data store, such as a file, or into an interchange format. This verb is paired with Import.	For this action, do not use verbs such as Extract or Backup.
Group (gp)
Arranges or associates one or more resources.	For this action, do not use verbs such as Aggregate, Arrange, Associate, or Correlate.
Import (ip)
Creates a resource from data that is stored in a persistent data store (such as a file) or in an interchange format. For example, the Import-CSV cmdlet imports data from a comma-separated value (CSV) file to objects that can be used by other cmdlets. This verb is paired with Export.	For this action, do not use verbs such as BulkLoad or Load.
Initialize (in)
Prepares a resource for use, and sets it to a default state.	For this action, do not use verbs such as Erase, Init, Renew, Rebuild, Reinitialize, or Setup.
Limit (l)
Applies constraints to a resource.	For this action, do not use a verb such as Quota.
Merge (mg)
Creates a single resource from multiple resources.	For this action, do not use verbs such as Combine or Join.
Mount (mt)
Attaches a named entity to a location. This verb is paired with Dismount.	For this action, do not use the verb Connect.
Out (o)
Sends data out of the environment. For example, the Out-Printer cmdlet sends data to a printer.	
Publish (pb)
Makes a resource available to others. This verb is paired with Unpublish.	For this action, do not use verbs such as Deploy, Release, or Install.
Restore (rr)
Sets a resource to a predefined state, such as a state set by Checkpoint. For example, the Restore-Computer cmdlet starts a system restore on the local computer.	For this action, do not use verbs such as Repair, Return, Undo, or Fix.
Save (sv)
Preserves data to avoid loss.	
Sync (sy)
Assures that two or more resources are in the same state.	For this action, do not use verbs such as Replicate, Coerce, or Match.
Unpublish (ub)	Makes a resource unavailable to others. This verb is paired with Publish.	For this action, do not use verbs such as Uninstall, Revert, or Hide.
Update (ud)
Brings a resource up-to-date to maintain its state, accuracy, conformance, or compliance. For example, the Update-FormatData cmdlet updates and adds formatting files to the current PowerShell console.	For this action, do not use verbs such as Refresh, Renew, Recalculate, or Re-index.
Diagnostic Verbs
PowerShell uses the System.Management.Automation.VerbsDiagnostic class to define actions that apply to diagnostics. The following table lists most of the defined verbs.
Verb (alias)	Action	Comments
Debug (db)	Examines a resource to diagnose operational problems.	For this action, do not use a verb such as Diagnose.
Measure (ms)	Identifies resources that are consumed by a specified operation, or retrieves statistics about a resource.	For this action, do not use verbs such as Calculate, Determine, or Analyze.
Ping (pi)
Use the Test verb.	
Repair (rp)	Restores a resource to a usable condition	For this action, do not use verbs such as Fix or Restore.
Resolve (rv)	Maps a shorthand representation of a resource to a more complete representation.	For this action, do not use verbs such as Expand or Determine.
Test (t)
Verifies the operation or consistency of a resource.	For this action, do not use verbs such as Diagnose, Analyze, Salvage, or Verify.
Trace (tr)
Tracks the activities of a resource.	For this action, do not use verbs such as Track, Follow, Inspect, or Dig.
Lifecycle Verbs
PowerShell uses the System.Management.Automation.VerbsLifeCycle class to define actions that apply to the lifecycle of a resource. The following table lists most of the defined verbs.
Verb (alias)	Action	Comments
Approve (ap)	Confirms or agrees to the status of a resource or process.	
Assert (as)
Affirms the state of a resource.	For this action, do not use a verb such as Certify.
Build (bd)
Creates an artifact (usually a binary or document) out of some set of input files (usually source code or declarative documents)	This verb was added in PowerShell v6
Complete (cp)	Concludes an operation.	
Confirm (cn)	Acknowledges, verifies, or validates the state of a resource or process.	For this action, do not use verbs such as Acknowledge, Agree, Certify, Validate, or Verify.
Deny (dn)
Refuses, objects, blocks, or opposes the state of a resource or process.	For this action, do not use verbs such as Block, Object, Refuse, or Reject.
Deploy (dp)	Sends an application, website, or solution to a remote target[s] in such a way that a consumer of that solution can access it after deployment is complete	This verb was added in PowerShell v6
Disable (d)
Configures a resource to an unavailable or inactive state. For example, the Disable-PSBreakpoint cmdlet makes a breakpoint inactive. This verb is paired with Enable.	For this action, do not use verbs such as Halt or Hide.
Enable (e)
Configures a resource to an available or active state. For example, the Enable-PSBreakpoint cmdlet makes a breakpoint active. This verb is paired with Disable.	For this action, do not use verbs such as Start or Begin.
Install (is)
Places a resource in a location, and optionally initializes it. This verb is paired with Uninstall.	For this action, do not a use verb such as Setup.
Invoke (i)
Performs an action, such as running a command or a method.	For this action, do not use verbs such as Run or Start.
Register (rg)	Creates an entry for a resource in a repository such as a database. This verb is paired with Unregister.	
Request (rq)	Asks for a resource or asks for permissions.	
Restart (rt)
Stops an operation and then starts it again. For example, the Restart-Service cmdlet stops and then starts a service.	For this action, do not use a verb such as Recycle.
Resume (ru)	Starts an operation that has been suspended. For example, the Resume-Service cmdlet starts a service that has been suspended. This verb is paired with Suspend.	
Start (sa)
Initiates an operation. For example, the Start-Service cmdlet starts a service. This verb is paired with Stop.	For this action, do not use verbs such as Launch, Initiate, or Boot.
Stop (sp)
Discontinues an activity. This verb is paired with Start.	For this action, do not use verbs such as End, Kill, Terminate, or Cancel.
Submit (sb)	Presents a resource for approval.	For this action, do not use a verb such as Post.
Suspend (ss)	Pauses an activity. For example, the Suspend-Service cmdlet pauses a service. This verb is paired with Resume.	For this action, do not use a verb such as Pause.
Uninstall (us)	Removes a resource from an indicated location. This verb is paired with Install.	
Unregister (ur)	Removes the entry for a resource from a repository. This verb is paired with Register.	For this action, do not use a verb such as Remove.
Wait (w)
Pauses an operation until a specified event occurs. For example, the Wait-Job cmdlet pauses operations until one or more of the background jobs are complete.	For this action, do not use verbs such as Sleep or Pause.
Security Verbs
PowerShell uses the System.Management.Automation.VerbsSecurity class to define actions that apply to security. The following table lists most of the defined verbs.
Verb (alias)	Action	Comments
Block (bl)
Restricts access to a resource. This verb is paired with Unblock.	For this action, do not use verbs such as Prevent, Limit, or Deny.
Grant (gr)
Allows access to a resource. This verb is paired with Revoke.	For this action, do not use verbs such as Allow or Enable.
Protect (pt)
Safeguards a resource from attack or loss. This verb is paired with Unprotect.	For this action, do not use verbs such as Encrypt, Safeguard, or Seal.
Revoke (rk)	Specifies an action that does not allow access to a resource. This verb is paired with Grant.	For this action, do not use verbs such as Remove or Disable.
Unblock (ul)	Removes restrictions to a resource. This verb is paired with Block.	For this action, do not use verbs such as Clear or Allow.
Unprotect (up)	Removes safeguards from a resource that were added to prevent it from attack or loss. This verb is paired with Protect.	For this action, do not use verbs such as Decrypt or Unseal.
