import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Viagem } from '../viagens.component';

@Injectable()
export class ViagensService {
    private _loading = false;

    get loading(): boolean {
        return this._loading;
    }

    constructor(private http: HttpClient) { }

    public getViagensByNomeDestinatario(nome: string, limit: number, offset: number) {
        this._loading = true;

        const promise = this.http.get('/api/viagens/' + nome + '/' + limit + '/' + offset + '/').toPromise();

        promise
            .then(() => {
                this._loading = false;
            })
            .catch(() => {
                this._loading = false;
            });

        return promise;
    }
}
