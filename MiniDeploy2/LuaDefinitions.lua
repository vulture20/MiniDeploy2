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

function installDotNet45(srvDrive)
	return deploy.startProcess(srcDrive .. "\\DotNet\\DotNet45\\NDP452-KB2901907-x86-x64-AllOS-ENU.exe", "/passive /norestart");
end

function installDotNet45LP(srvDrive)
	return deploy.startProcess(srcDrive .. "\\DotNet\\DotNet45\\dotNetFx45LP_Full_x86_x64de.exe", "/passive /norestart");
end

function installAVClient(srcDrive)
	return deploy.startProcess(srcDrive .. "\\Software\\GdataClient\\GDClientPck.exe", "");
end

function installFlashPlayerActiveX(srcDrive)
	return deploy.startProcess("msiexec", "/i \"" .. srcDrive .. "\\Flash Player\\install_flash_player18_active_x.msi\" /passive /norestart");
end

function installFlashPlayerPlugin(srcDrive)
	return deploy.startProcess("msiexec", "/i \"" .. srcDrive .. "\\Flash Player\\install_flash_player18_plugin.msi\" /passive /norestart");
end

function installCommunicator(srcDrive)
	return deploy.startProcess("msiexec", "/i \"" .. srcDrive .. "\\Communicator 2007 R2\\Communicator.msi\" /passive /norestart");
end

function installCommunicatorHotfix(srcDrive)
	return deploy.startProcess("msiexec", "/p \"" .. srcDrive .. "\\Communicator 2007 R2\\Hotfix OCS R2\\Communicator.msp\" REINSTALL=ALL REINSTALLMODE=omus /passive /norestart");
end

function installMSSQLNativeClient(srcDrive)
	if (deploy.is64Bit()) then
		return deploy.startProcess("msiexec", "/i \"" .. srcDrive .. "\\SQL Native Client\\sqlncli 2008 x64.msi\" /passive /norestart");
	else
		return deploy.startProcess("msiexec", "/i \"" .. srcDrive .. "\\SQL Native Client\\sqlncli 2008 x86.msi\" /passive /norestart");
	end
end

function deinstallAcrobatReader(srcDrive)
	return deploy.startProcess("msiexec", "/x {AC76BA86-7AD7-1031-7B44-AB0000000001} /qn /norestart");
end

function installAcrobatReader(srcDrive)
	return deploy.startProcess(srcDrive .. "\\Adobe\\AdbeRdr11008_de_DE\\setup.exe", "/sAll /rs /rps /msi TRANSFORMS=AcroRead.mst");
end

function installVirtualCloneDrive(srcDrive)
	ret = true;

	if (startProcess("certutil", "-addstore \"TrustedPublisher\" " .. srcDrive .. "\\Software\\SlySoft\\Elaborate.p7b") != true) then ret = false; end
	if (startProcess(srcDrive .. "\\Software\\SlySoft\\SetupVirtualCloneDrive5440.exe", "/S") != true) then ret = false; end

	return ret;
end
