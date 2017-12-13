# VERSION: 2
#
# Env rules for AEGIS 
# include this file from within ipc-custom.re
#
# Create in aegisUA1Res by default


# Ensure that files created in the aegis project directory are stored on the correct resource.
#
aegis_acSetRescSchemeForCreate {
  if ($objPath like "/iplant/home/shared/aegis/*") {
    msiSetDefaultResc("aegisUA1Res", "forced");
  }
}


# Ensure that replicas of the files stored in the aegis project directory are stored on the correct 
# resource.
#
aegis_acSetRescSchemeForRepl { 
  if ($objPath like "/iplant/home/shared/aegis/*") {
    msiSetDefaultResc("aegisReplRes", "forced"); 
  }
}

