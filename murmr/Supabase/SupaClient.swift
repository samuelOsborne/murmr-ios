//
//  SupabaseClient.swift
//  SupabaseAuth
//
//  Created by Sam on 16/12/2023.
//

import Foundation
import Supabase

class SupaClient {
    static let client = SupabaseClient(supabaseURL: URL(string: Config.SUPABASE_URL)!, supabaseKey: Config.SUPABASE_ANON_KEY)

    // Todo replace in newer version of supabase
    // https://github.com/supabase-community/supabase-swift/pull/199
    static let storageClient = SupabaseClient(supabaseURL: URL(string: Config.SUPABASE_URL)!, supabaseKey: Config.SUPABASE_ANON_KEY, options: SupabaseClientOptions(db: SupabaseClientOptions.DatabaseOptions(schema: "storage")))
}
