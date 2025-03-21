# frozen_string_literal: true

require 'rexml/document'

module SamlIdpMetadata
  #
  # SAML IdP metadata parser with REXML
  #
  class Parser
    attr_reader :xml, :xmlns, :entity_id, :sso_http_redirect_url, :sso_http_post_url, :slo_url, :nameid_format,
                :x509_certificate

    def initialize(xml:)
      @xml = xml
      @doc = REXML::Document.new(xml)

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
      @sso_http_post_url = parse_sso_http_post_url || parse_sso_http_redirect_url
      @slo_url = parse_slo_url
      @nameid_format = parse_nameid_format
      @x509_certificate = parse_x509_certificate

      self
    end

    def validate_xmlns
      xmlns == 'urn:oasis:names:tc:SAML:2.0:metadata'
    end

    def ensure_params?
      !entity_id.nil? && ((!sso_http_redirect_url.nil? && !sso_http_post_url.nil?)) && !x509_certificate.nil?
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
      # Handle EntitiesDescriptor case
      if @doc.root.name == 'EntitiesDescriptor'
        find_with_namespace(@doc.root.elements, 'EntityDescriptor')
      else
        @doc.root
      end
    end

    def parse_entity_id
      entity_descriptor&.attributes&.[]('entityID')
    end

    def parse_xmlns
      if entity_descriptor&.attributes&.[]('xmlns:md')
        entity_descriptor.attributes['xmlns:md']
      else
        entity_descriptor&.attributes&.[]('xmlns')
      end
    end

    def idp_descriptor
      find_with_namespace(entity_descriptor&.elements, 'IDPSSODescriptor')
    end

    def parse_sso_http_redirect_url
      services = find_all_with_namespace(idp_descriptor&.elements, 'SingleSignOnService')
      return nil if services.empty?

      # If there's only one service
      if services.size == 1
        return services.first.attributes['Location']
      end

      # Find service with HTTP-Redirect binding
      services.each do |service|
        binding = service.attributes['Binding']
        if binding == 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'
          return service.attributes['Location']
        end
      end

      nil
    end

    def parse_sso_http_post_url
      services = find_all_with_namespace(idp_descriptor&.elements, 'SingleSignOnService')
      return nil if services.empty?

      # If there's only one service
      if services.size == 1
        return services.first.attributes['Location']
      end

      # Find service with HTTP-POST binding
      services.each do |service|
        binding = service.attributes['Binding']
        if binding == 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'
          return service.attributes['Location']
        end
      end

      nil
    end

    def parse_slo_url
      services = find_all_with_namespace(idp_descriptor&.elements, 'SingleLogoutService')
      return nil if services.empty?

      # If there's only one service
      if services.size == 1
        return services.first.attributes['Location']
      end

      # Find service with HTTP-Redirect binding
      services.each do |service|
        binding = service.attributes['Binding']
        if binding == 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'
          return service.attributes['Location']
        end
      end

      nil
    end

    def parse_nameid_format
      formats = find_all_with_namespace(idp_descriptor&.elements, 'NameIDFormat')
      return nil if formats.empty?

      # Return the last format if there are multiple
      formats.last.text
    end

    def parse_x509_certificate
      key_descriptors = find_all_with_namespace(idp_descriptor&.elements, 'KeyDescriptor')
      return nil if key_descriptors.empty?

      # Use the last key descriptor
      key_descriptor = key_descriptors.last

      # Navigate the XML structure to find the X509Certificate element
      key_info = find_with_namespace(key_descriptor.elements, 'KeyInfo') ||
                 find_element(key_descriptor.elements, 'ds:KeyInfo')

      return nil unless key_info

      x509_data = find_with_namespace(key_info.elements, 'X509Data') ||
                  find_element(key_info.elements, 'ds:X509Data')

      return nil unless x509_data

      cert_element = find_with_namespace(x509_data.elements, 'X509Certificate') ||
                     find_element(x509_data.elements, 'ds:X509Certificate')

      cert_element&.text
    end

    # Helper methods to handle namespace variations
    def find_with_namespace(elements, name)
      return nil if elements.nil?

      # Try with different namespace prefixes
      element = find_element(elements, name) ||
                find_element(elements, "md:#{name}") ||
                find_element(elements, "saml:#{name}")

      element
    end

    def find_all_with_namespace(elements, name)
      return [] if elements.nil?

      # Collect elements with different namespace prefixes
      result = []
      result.concat(find_all_elements(elements, name))
      result.concat(find_all_elements(elements, "md:#{name}"))
      result.concat(find_all_elements(elements, "saml:#{name}"))

      result
    end

    def find_element(elements, name)
      return nil if elements.nil?
      elements.to_a.find { |e| e.name == name }
    end

    def find_all_elements(elements, name)
      return [] if elements.nil?
      elements.to_a.select { |e| e.name == name }
    end
  end
end
