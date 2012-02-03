# encoding: utf-8
#
# Copyright (c) Infopark AG
#
def intercept_scalapi_calls
  ::Test::Scalapi.intercept_scalapi_calls
end

def intercepted_calls
  ::Test::Scalapi.resource
end

def instantiate_model(*args)
  ::Test::Scalapi.instantiate_model(*args)
end
