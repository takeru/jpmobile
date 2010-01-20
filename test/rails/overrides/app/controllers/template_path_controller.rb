# -*- coding: utf-8 -*-
class TemplatePathController < ApplicationController
  def index
    @q = params[:q]
  end
end

