function openDeviceManager()
	return deploy.startProcess('devmgmt.msc', '');
end

function disableGames()
	ret = true;
	if (not deploy.startProcess('dism.exe', '/online /Disable-Feature:InboxGames')) then ret = false; end
	if (not deploy.startProcess('dism.exe', '/online /Disable-Feature:"More Games"')) then ret = false; end
	if (not deploy.startProcess('dism.exe', '/online /Disable-Feature:"Internet Games"')) then ret = false; end
	return ret;
end

function enableTelnetClient()
	return deploy.startProcess('dism.exe', '/online /Enable-Feature:TelnetClient');
end

function enableFirewallRule(rule)
	return deploy.startProcess('net.sh', 'advfirewall firewall set rule group="' .. rule .. '" new enable=yes')
end

function setFirewallRules()
	ret = true;

	if (not enableFirewallRule("Datei- und Druckerfreigabe")) then ret = false; end
	if (not enableFirewallRule("Remotedesktop - RemoteFX")) then ret = false; end
	if (not enableFirewallRule("Remotedesktop")) then ret = false; end
	if (not enableFirewallRule("Remotevolumeverwaltung")) then ret = false; end
	if (not enableFirewallRule("Windows-Firewallremoteverwaltung")) then ret = false; end
	if (not enableFirewallRule("Windows-Remoteverwaltung")) then ret = false; end
	if (not enableFirewallRule("Remoteverwaltung geplanter Aufgaben")) then ret = false; end
	if (not enableFirewallRule("Remote-Ereignisprotokollverwaltung")) then ret = false; end
	if (not enableFirewallRule("Windows-Verwaltungsinstrumentation (WMI)")) then ret = false; end
	if (not enableFirewallRule("Remotedienstverwaltung")) then ret = false; end
	if (not enableFirewallRule("Remoteunterstützung")) then ret = false; end
	if (not deploy.startProcess('net.sh', 'advfirewall firewall add rule name="Block SSDP" dir=out action=block protocol=UDP remoteport=1900')) then ret = false; end
	if (not deploy.startProcess('net.sh', 'advfirewall firewall add rule name="Allow RDP" dir=in action=allow protocol=TCP localport=3389')) then ret = false; end
	if (not deploy.startProcess('net.sh', 'advfirewall firewall add rule name="AVKClient" dir=in action=allow program="C:\\Program Files (x86)\\G Data\\AVKClient\\AVKCl.exe" enable=yes profile=any protocol=tcp edge=yes')) then ret = false; end

	return ret;
end

function copyNetViewer(srcDrive)
	if (not deploy.isDirectory(deploy.getProgramPath() .. "NetViewer")) then
		if (not deploy.createDirectory(deploy.getProgramPath() .. "NetViewer")) then
			return false;
		end
	else
		if (deploy.fileExists(deploy.getProgramPath() .. "NetViewer\\Netviewer Client.exe")) then
			return true;
		end
		if (not deploy.fileCopy(srcDrive .. "\\NetViewer\\Netviewer Client.exe", deploy.getProgramPath() .. "NetViewer\\Netviewer Client.exe")) then
			return false;
		end
		if (deploy.fileExists(deploy.getProgramPath() .. "NetViewer\\Netviewer Client.exe")) then
			return true;
		else
			return false;
		end
	end
end

function copyInfoBox(srcDrive)
	if (not deploy.isDirectory(deploy.getProgramPath() .. "InfoBox")) then
		if (not deploy.createDirectory(deploy.getProgramPath() .. "InfoBox")) then
			return false;
		end
	else
		if (deploy.fileExists(deploy.getProgramPath() .. "InfoBox\\Infobox.exe")) then
			return true;
		end
		if (not deploy.fileCopy(srcDrive .. "\\InfoBox\\Infobox.exe", deploy.getProgramPath() .. "InfoBox\\Infobox.exe")) then
			return false;
		end
		if (deploy.fileExists(deploy.getProgramPath() .. "InfoBox\\Infobox.exe")) then
			return true;
		else
			return false;
		end
	end
end
