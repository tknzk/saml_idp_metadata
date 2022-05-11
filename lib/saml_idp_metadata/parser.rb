# frozen_string_literal: true

require 'active_support/dependencies/autoload'
require 'active_support/core_ext'

module SamlIdpMetadata
  #
  # SAML IdP metadata parser
  #
  class Parser
    attr_reader :xml, :xmlns, :entity_id, :sso_http_redirect_url, :sso_http_post_url, :slo_url, :nameid_format,
                :x509_certificate

    def initialize(xml:)
      @xml = xml
      @hash = Hash.from_xml(xml)

      @xmlns = nil
      @entity_id = nil
      @sso_http_redirect_url = nil
      @sso_http_post_url = nil
      @slo_url = nil
      @nameid_format = nil
      @x509_certificate = nil
    end

    def self.call(xml:)
      new(xml: xml).call
    end

    def call
      @xmlns = parse_xmlns

      @entity_id = parse_entity_id
      @sso_http_redirect_url = parse_sso_http_redirect_url
      @sso_http_post_url = parse_sso_http_post_url
      @slo_url = parse_slo_url
      @nameid_format = parse_nameid_format
      @x509_certificate = parse_x509_certificate

      self
    end

    def validate_xmlns
      xmlns == 'urn:oasis:names:tc:SAML:2.0:metadata'
    end

    def ensure_params?
      entity_id.present? && (sso_http_redirect_url.present? && sso_http_post_url.present?) && x509_certificate.present?
    end

    def build_params
      {
        entity_id: entity_id,
        sso_http_redirect_url: sso_http_redirect_url,
        sso_http_post_url: sso_http_post_url,
        certificate: x509_certificate,
        slo_url: slo_url,
        nameid_format: nameid_format,
        metadata: xml
      }
    end

    private

    def entity_descriptor
      if @hash['EntitiesDescriptor'].present?
        @hash['EntitiesDescriptor']['EntityDescriptor']
      else
        @hash['EntityDescriptor']
      end
    end

    def parse_entity_id
      entity_descriptor['entityID']
    end

    def parse_xmlns
      entity_descriptor.key?('xmlns:md') ? entity_descriptor['xmlns:md'] : entity_descriptor['xmlns']
    end

    def parse_sso_http_redirect_url
      return nil if entity_descriptor.dig('IDPSSODescriptor', 'SingleSignOnService').nil?

      single_signon_services = entity_descriptor['IDPSSODescriptor']['SingleSignOnService']

      return single_signon_services['Location'] if single_signon_services.is_a?(Hash)

      single_signon_services.each do |service|
        return service['Location'] if service['Binding'] == 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'
      end
    end

    def parse_sso_http_post_url
      return nil if entity_descriptor.dig('IDPSSODescriptor', 'SingleSignOnService').nil?

      single_signon_services = entity_descriptor['IDPSSODescriptor']['SingleSignOnService']

      return single_signon_services['Location'] if single_signon_services.is_a?(Hash)

      single_signon_services.each do |service|
        return service['Location'] if service['Binding'] == 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'
      end
    end

    def parse_slo_url
      return nil if entity_descriptor.dig('IDPSSODescriptor', 'SingleLogoutService').nil?

      single_logout_services = entity_descriptor['IDPSSODescriptor']['SingleLogoutService']

      return single_logout_services['Location'] if single_logout_services.is_a?(Hash)

      single_logout_services.each do |service|
        return service['Location'] if service['Binding'] == 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'
      end
    end

    def parse_nameid_format
      return nil if entity_descriptor.dig('IDPSSODescriptor', 'NameIDFormat').nil?

      if entity_descriptor['IDPSSODescriptor']['NameIDFormat'].instance_of?(Array)
        entity_descriptor['IDPSSODescriptor']['NameIDFormat'].last
      else
        entity_descriptor['IDPSSODescriptor']['NameIDFormat']
      end
    end

    def parse_x509_certificate
      return nil if entity_descriptor.dig('IDPSSODescriptor', 'KeyDescriptor').nil?

      if entity_descriptor['IDPSSODescriptor']['KeyDescriptor'].instance_of?(Array)
        entity_descriptor['IDPSSODescriptor']['KeyDescriptor'].last['KeyInfo']['X509Data']['X509Certificate']
      else
        entity_descriptor['IDPSSODescriptor']['KeyDescriptor']['KeyInfo']['X509Data']['X509Certificate']
      end
    end
  end
end
